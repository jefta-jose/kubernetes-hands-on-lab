# Exercise 03 — Mount a PVC into a Pod

## Concept

A Pod consumes persistent storage through a `persistentVolumeClaim` volume. The container then mounts that volume at a filesystem path using `volumeMounts`.

The Pod does not reference the underlying PV or storage implementation.

## Task

Complete `exercise/pod.yaml` so that:

- The Pod references the `app-data` PVC
- The volume and volume mount share the name `data`
- The volume is mounted at `/data`

## Run

```bash
cd exercises/03-mount-pvc-in-pod
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/pvc.yaml
kubectl apply -f exercise/pod.yaml
kubectl wait --for=condition=Ready pod/storage-client -n pv-lab-03 --timeout=120s
```

Write and read a file:

```bash
kubectl exec -n pv-lab-03 storage-client -- sh -c 'echo "persistent hello" > /data/message.txt'
kubectl exec -n pv-lab-03 storage-client -- cat /data/message.txt
```

Inspect the mount relationship:

```bash
kubectl describe pod storage-client -n pv-lab-03
kubectl get pvc -n pv-lab-03
kubectl get pv
```

## Progressive hints

1. `claimName` must match PVC metadata.name.
2. `volumes[].name` and `volumeMounts[].name` must match each other.
3. `mountPath` is the path visible inside the container.

## Expected result

The Pod becomes `Ready`, and reading `/data/message.txt` prints:

```text
persistent hello
```

## Common errors

### `volumeMounts[0].name: Not found`

The mount name does not match the Pod volume name.

### Pod remains `Pending`

Inspect the PVC and Pod:

```bash
kubectl describe pvc app-data -n pv-lab-03
kubectl describe pod storage-client -n pv-lab-03
```

### `No such file or directory`

Confirm the mount path is `/data` and that the Pod is running.

## Solution

```bash
kubectl apply -f solution/namespace.yaml
kubectl apply -f solution/pvc.yaml
kubectl apply -f solution/pod.yaml
```

## Cleanup

```bash
kubectl delete namespace pv-lab-03
```
