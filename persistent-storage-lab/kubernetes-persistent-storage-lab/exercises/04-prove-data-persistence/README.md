# Exercise 04 — Prove Data Survives Pod Replacement

## Concept

A Pod and its writable container filesystem are ephemeral. A PVC has an independent lifecycle. Deleting a Pod does not delete its claim or the bound PV.

## Task

Complete both Pod manifests:

- The writer Pod must mount `shared-data` at `/data` and create `/data/identity.txt`
- The reader Pod must mount the same claim at the same path and remain running

## Run

```bash
cd exercises/04-prove-data-persistence
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/pvc.yaml
kubectl apply -f exercise/writer-pod.yaml
kubectl wait --for=condition=Ready pod/writer -n pv-lab-04 --timeout=120s
```

Verify the original file:

```bash
kubectl exec -n pv-lab-04 writer -- cat /data/identity.txt
```

Delete the writer Pod only:

```bash
kubectl delete pod writer -n pv-lab-04
kubectl get pvc -n pv-lab-04
```

Create the replacement reader:

```bash
kubectl apply -f exercise/reader-pod.yaml
kubectl wait --for=condition=Ready pod/reader -n pv-lab-04 --timeout=120s
kubectl exec -n pv-lab-04 reader -- cat /data/identity.txt
```

## Progressive hints

1. Both Pods must use `claimName: shared-data`.
2. Both mounts must use `/data`.
3. The writer command should redirect text into `/data/identity.txt` before sleeping.

## Expected result

The reader prints the file written by the deleted writer Pod:

```text
created by the first pod
```

The PVC remains `Bound` between Pod deletion and recreation.

## Common errors

### Reader sees an empty directory

Confirm both Pods reference the same claim and mount path.

### PVC was deleted accidentally

Recreate the namespace and start again. With the default `Delete` reclaim policy, deleting the PVC may delete the underlying storage.

### Pod cannot attach the volume

Wait for the old Pod to terminate fully:

```bash
kubectl get pod writer -n pv-lab-04
kubectl get events -n pv-lab-04 --sort-by=.lastTimestamp
```

## Solution

Apply the solution files in the same order as the exercise files.

## Cleanup

```bash
kubectl delete namespace pv-lab-04
```
