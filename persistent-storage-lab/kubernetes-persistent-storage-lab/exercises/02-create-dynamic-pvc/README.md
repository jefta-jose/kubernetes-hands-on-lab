# Exercise 02 — Create a Dynamically Provisioned PVC

## Concept

A PersistentVolumeClaim describes storage requirements. With dynamic provisioning, a StorageClass provisioner creates the underlying storage and a matching PersistentVolume.

## Task

Complete `exercise/pvc.yaml` with:

- The local cluster's default StorageClass
- A `1Gi` storage request
- The `ReadWriteOnce` access mode

## Run

```bash
cd exercises/02-create-dynamic-pvc
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/pvc.yaml
kubectl get pvc -n pv-lab-02 -w
```

Press `Ctrl+C` after the claim becomes `Bound`.

Inspect the result:

```bash
kubectl describe pvc app-data -n pv-lab-02
kubectl get pv
```

## Progressive hints

1. Find the default class with `kubectl get sc`.
2. The access mode is written as `ReadWriteOnce`, not `RWO`, inside YAML.
3. Storage requests belong under `spec.resources.requests.storage`.

## Expected result

The PVC should become `Bound`, and `kubectl get pv` should show a dynamically created PV with approximately `1Gi` capacity.

If the StorageClass uses `WaitForFirstConsumer`, the claim may remain `Pending` until a Pod consumes it. That behaviour is explored in exercise 05.

## Common errors

### PVC remains `Pending`

```bash
kubectl describe pvc app-data -n pv-lab-02
kubectl get events -n pv-lab-02 --sort-by=.lastTimestamp
```

Check for a nonexistent StorageClass or provisioning errors.

### `storageclass.storage.k8s.io "..." not found`

Use the exact class name from:

```bash
kubectl get sc
```

### Requested access mode is unsupported

Use `ReadWriteOnce` for the local Minikube host-path provisioner.

## Solution

```bash
kubectl apply -f solution/namespace.yaml
kubectl apply -f solution/pvc.yaml
```

## Cleanup

```bash
kubectl delete namespace pv-lab-02
```
