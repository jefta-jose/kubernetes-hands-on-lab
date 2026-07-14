# Exercise 07 — Use a Generic Ephemeral Volume

## Concept

A generic ephemeral volume uses a PVC template inside the Pod specification. Kubernetes creates a PVC for that Pod, dynamically provisions a PV, and deletes the claim when the Pod is deleted.

The storage has normal PVC capabilities, but its lifecycle is intentionally tied to one Pod.

## Task

Complete the Pod so that:

- The ephemeral claim requests `1Gi`
- The access mode is `ReadWriteOnce`
- The volume is mounted at `/workspace`
- The container creates `/workspace/result.txt`

## Run

```bash
cd exercises/07-generic-ephemeral-volume
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/pod.yaml
kubectl wait --for=condition=Ready pod/ephemeral-worker -n pv-lab-07 --timeout=120s
```

Inspect the automatically created claim:

```bash
kubectl get pvc -n pv-lab-07
kubectl get pv
kubectl exec -n pv-lab-07 ephemeral-worker -- cat /workspace/result.txt
```

Delete the Pod:

```bash
kubectl delete pod ephemeral-worker -n pv-lab-07
kubectl get pvc -n pv-lab-07
```

## Progressive hints

1. The claim template uses the same `accessModes` and `resources.requests.storage` structure as a normal PVC.
2. The generated claim name is based on the Pod and volume names.
3. The mount path must match the path used by the container command.

## Expected result

While the Pod exists, a PVC named similar to this appears:

```text
ephemeral-worker-workspace
```

After the Pod is deleted, the generated PVC is deleted automatically.

## Common errors

### Pod remains Pending

Check whether the cluster has a default StorageClass:

```bash
kubectl get sc
kubectl describe pod ephemeral-worker -n pv-lab-07
```

### PVC remains after Pod deletion

Wait briefly and check owner references:

```bash
kubectl get pvc -n pv-lab-07 -o yaml
```

### File is missing

Confirm the command writes to the same path used by `mountPath`.

## Solution

Apply `solution/namespace.yaml` and `solution/pod.yaml`.

## Cleanup

```bash
kubectl delete namespace pv-lab-07
```
