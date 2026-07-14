# Exercise 08 — Final StatefulSet Persistence Challenge

## Concept

A StatefulSet gives each replica a stable identity and can generate a dedicated PVC from a `volumeClaimTemplates` entry.

This challenge combines:

- A custom StorageClass
- `WaitForFirstConsumer`
- Dynamic provisioning
- A StatefulSet
- A generated PVC
- A persistent mount
- Data surviving Pod replacement

## Task

Complete the manifests so that:

1. `pv-lab-final` uses the Minikube host-path provisioner.
2. Provisioning waits for the first consumer.
3. The StatefulSet creates one replica named `counter-0`.
4. Its claim template is named `data`.
5. The claim requests `1Gi` with `ReadWriteOnce`.
6. The claim is mounted at `/data`.
7. Every container start increments `/data/start-count`.

Do not open the solution until your Pod can be deleted and recreated with an incremented count.

## Run

```bash
cd exercises/08-final-statefulset-challenge
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/storageclass.yaml
kubectl apply -f exercise/service.yaml
kubectl apply -f exercise/statefulset.yaml
kubectl rollout status statefulset/counter -n pv-lab-08 --timeout=120s
```

Inspect the generated claim:

```bash
kubectl get pod,pvc -n pv-lab-08
kubectl get pv
```

Read the first start count:

```bash
kubectl exec -n pv-lab-08 counter-0 -- cat /data/start-count
kubectl exec -n pv-lab-08 counter-0 -- cat /data/status.txt
```

Delete the Pod, not the StatefulSet or PVC:

```bash
kubectl delete pod counter-0 -n pv-lab-08
kubectl wait --for=condition=Ready pod/counter-0 -n pv-lab-08 --timeout=120s
```

Read the persisted counter again:

```bash
kubectl exec -n pv-lab-08 counter-0 -- cat /data/start-count
kubectl exec -n pv-lab-08 counter-0 -- cat /data/status.txt
```

## Progressive hints

1. Reuse the provisioner and binding mode from exercise 05.
2. A StatefulSet selector must match the Pod template labels.
3. The name in `volumeMounts` must match the claim template metadata.name.
4. The generated PVC name follows `<claim-template>-<statefulset>-<ordinal>`.
5. Initialise the counter file only when it does not exist, then increment its numeric value.

## Expected result

The generated PVC should be named:

```text
data-counter-0
```

On the first start, `/data/start-count` should contain `1`.

After deleting `counter-0`, the StatefulSet recreates it. The same PVC is mounted, and `/data/start-count` should contain `2`.

The Pod identity remains `counter-0`, while the container instance is replaced.

## Common errors

### StatefulSet does not create a Pod

```bash
kubectl describe statefulset counter -n pv-lab-08
kubectl get events -n pv-lab-08 --sort-by=.lastTimestamp
```

### PVC remains Pending

Confirm the Pod exists and the StorageClass uses `WaitForFirstConsumer`:

```bash
kubectl get pod,pvc -n pv-lab-08
kubectl get sc pv-lab-final -o yaml
```

### Pod reports an unbound immediate PVC

Check that the StatefulSet claim template references the correct StorageClass name.

### Counter resets to 1

The Pod is probably writing outside the mounted path or using a different generated claim.

Inspect:

```bash
kubectl describe pod counter-0 -n pv-lab-08
kubectl get pvc data-counter-0 -n pv-lab-08 -o yaml
```

### Shell reports an arithmetic error

Ensure the counter file contains only an integer and the script uses shell arithmetic:

```sh
count=$((count + 1))
```

## Solution

Apply the files under `solution/`.

## Cleanup

```bash
kubectl delete namespace pv-lab-08
kubectl delete storageclass pv-lab-final
```

The class uses `Delete`, so the generated PV and underlying Minikube host-path data should be removed after the claim is deleted.
