# Exercise 06 — Static Provisioning and the Retain Policy

## Concept

With static provisioning, an administrator prepares storage first and creates a PV that points to it. A PVC then binds to the existing PV.

A `Retain` reclaim policy preserves the underlying data after the claim is deleted. The PV changes to `Released` and requires administrator action before reuse.

## Task

Complete the files so that:

- A directory is created on the Minikube node
- A no-provisioner StorageClass represents local storage
- A `2Gi` local PV points to `/data/pv-lab-retain`
- The PV is restricted to the `minikube` node
- The reclaim policy is `Retain`
- A PVC and Pod bind to and write to the volume

## Run

Prepare the node directory:

```bash
cd exercises/06-static-pv-and-retain
bash exercise/prepare-node.sh
```

Apply resources:

```bash
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/storageclass.yaml
kubectl apply -f exercise/pv.yaml
kubectl apply -f exercise/pvc.yaml
kubectl apply -f exercise/pod.yaml
kubectl wait --for=condition=Ready pod/local-writer -n pv-lab-06 --timeout=120s
```

Verify the data:

```bash
kubectl exec -n pv-lab-06 local-writer -- cat /data/retained.txt
minikube ssh -- cat /data/pv-lab-retain/retained.txt
```

Observe the reclaim policy:

```bash
kubectl delete pod local-writer -n pv-lab-06
kubectl delete pvc local-data -n pv-lab-06
kubectl get pv pv-lab-retain-pv
```

## Progressive hints

1. A manually managed local class uses `kubernetes.io/no-provisioner`.
2. Local storage should use `WaitForFirstConsumer`.
3. The PV field is `persistentVolumeReclaimPolicy: Retain`.
4. A local PV requires node affinity.
5. The Minikube node hostname is normally `minikube`.

## Expected result

Before claim deletion, the PV is `Bound`.

After deleting the Pod and PVC, the PV becomes:

```text
STATUS     RECLAIM POLICY
Released   Retain
```

The file still exists on the Minikube node.

## Common errors

### PVC remains Pending

Compare capacity, access mode, StorageClass, and node affinity:

```bash
kubectl describe pvc local-data -n pv-lab-06
kubectl describe pv pv-lab-retain-pv
```

### Pod cannot mount the local path

Confirm the directory exists:

```bash
minikube ssh -- ls -ld /data/pv-lab-retain
```

### Incorrect node name

```bash
kubectl get nodes
```

Replace `minikube` in the PV node affinity if your node has another name.

### Recreated PVC does not bind to the Released PV

This is expected. A retained PV is not automatically `Available`. The administrator must clean the data and remove the old claim reference or recreate the PV object.

## Solution

Use the files under `solution/`.

## Cleanup

```bash
kubectl delete namespace pv-lab-06 --ignore-not-found
kubectl delete pv pv-lab-retain-pv --ignore-not-found
kubectl delete storageclass pv-lab-static --ignore-not-found
minikube ssh -- "sudo rm -rf /data/pv-lab-retain"
```
