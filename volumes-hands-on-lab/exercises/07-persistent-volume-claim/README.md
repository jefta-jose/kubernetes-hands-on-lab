# Exercise 07 — Persist Data Across Pod Replacement

## Concept

An `emptyDir` belongs to a Pod.

A PersistentVolumeClaim represents storage whose lifecycle can outlive an individual Pod. A replacement Pod can mount the same claim and recover the previous data.

This exercise depends on a default dynamic StorageClass, which Docker Desktop Kubernetes normally provides.

## Task

Complete the PVC and Pod so that:

- The claim is named `lab-data`.
- It requests `256Mi`.
- It uses `ReadWriteOnce`.
- The Pod mounts it at `/data`.
- The counter stored in `/data/counter.txt` survives Pod deletion and recreation.

## Check storage support

```bash
kubectl get storageclass
```

At least one StorageClass should be marked as default.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /tmp/07
cp exercise/pvc.yaml /tmp/07/pvc.yaml
cp exercise/pod.yaml /tmp/07/pod.yaml
nano /tmp/07/pvc.yaml
nano /tmp/07/pod.yaml
kubectl apply --dry-run=client -f /tmp/07/
kubectl apply -f /tmp/07/
kubectl get pvc -n volumes-lab
kubectl wait --for=condition=Ready pod/pvc-writer -n volumes-lab --timeout=120s
```

## Test persistence

Read the counter:

```bash
kubectl exec -n volumes-lab pvc-writer -- cat /data/counter.txt
```

Delete only the Pod:

```bash
kubectl delete pod pvc-writer -n volumes-lab
```

Recreate it with the same manifest:

```bash
kubectl apply -f /tmp/07/pod.yaml
kubectl wait --for=condition=Ready pod/pvc-writer -n volumes-lab --timeout=120s
```

Read the counter again:

```bash
kubectl exec -n volumes-lab pvc-writer -- cat /data/counter.txt
```

The value should continue rather than reset.

## Progressive hints

<details>
<summary>Hint 1</summary>

The PVC access mode is `ReadWriteOnce`.

</details>

<details>
<summary>Hint 2</summary>

The Pod volume type is `persistentVolumeClaim`.

</details>

<details>
<summary>Hint 3</summary>

The claim reference field is `claimName`.

</details>

## Expected result

- The PVC becomes `Bound`.
- The counter increases.
- Deleting and recreating the Pod does not reset the counter.
- Deleting the PVC removes the claim and may remove the backing volume depending on the StorageClass reclaim policy.

## Common errors

### PVC remains `Pending`

Check the default StorageClass:

```bash
kubectl get storageclass
kubectl describe pvc lab-data -n volumes-lab
```

### Pod cannot mount the claim

Inspect events:

```bash
kubectl describe pod pvc-writer -n volumes-lab
```

### Counter resets

Confirm that you deleted only the Pod, not the PVC.

## Cleanup

```bash
kubectl delete pod pvc-writer -n volumes-lab --ignore-not-found
kubectl delete pvc lab-data -n volumes-lab --ignore-not-found
```
