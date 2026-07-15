# Exercise 05 — Delay Provisioning with WaitForFirstConsumer

## Concept

A StorageClass controls how and when storage is provisioned.

With `Immediate` binding, Kubernetes asks the storage provisioner to create a volume as soon as the PVC is created. At that point, Kubernetes may not yet know which Node will run the Pod. That can be a problem for storage that is tied to a particular Node or availability zone.

With `WaitForFirstConsumer` binding, Kubernetes waits until a Pod actually uses the PVC. The scheduler can then choose a Node first, and the storage provisioner can create a volume that is suitable for that Node. The word *consumer* refers to the Pod that consumes, or uses, the claim.

### What happens in this exercise

The resources take part in the following sequence:

1. The `StorageClass` tells Kubernetes to use the Minikube host-path provisioner and to wait for a consumer.
2. The `PersistentVolumeClaim` asks for 1 GiB from that StorageClass. It stays `Pending` because no Pod uses it yet. This is expected, not an error.
3. The `Pod` references the claim. The scheduler chooses the `minikube` Node and records that choice on the PVC using the `volume.kubernetes.io/selected-node` annotation.
4. The host-path provisioner reads the selected Node and creates storage on that Node.
5. Kubernetes creates a `PersistentVolume`, binds it to the PVC, and starts the Pod with the volume mounted at `/data`.

This ordering matters for host-path storage because the data directory exists on one Node's filesystem. In a multi-node cluster, creating it for the wrong Node would leave the scheduled Pod unable to use it.

### Why this exercise includes RBAC

Kubernetes components do not automatically have permission to read or change every resource. The Minikube storage provisioner runs with the identity of the `storage-provisioner` ServiceAccount in the `kube-system` namespace. To inspect the scheduler's selected Node, that identity must be allowed to read Node resources.

Some Minikube installations bind the provisioner to a built-in role that can manage PVs and PVCs but cannot read Nodes. Immediate binding may still work because it does not depend on a scheduler-selected Node. With `WaitForFirstConsumer`, the missing permission becomes visible and provisioning stops with a `nodes "minikube" is forbidden` error.

The `rbac.yaml` manifest fixes that gap using two resources:

- `ClusterRole` defines the permission: it allows only the `get` action on Nodes. A cluster-scoped role is required because Nodes do not belong to a namespace.
- `ClusterRoleBinding` gives that role to the `kube-system/storage-provisioner` ServiceAccount.

This follows the principle of least privilege: the provisioner can read the selected Node, but this role does not let it create, modify, or delete Nodes.

## Task

Complete the manifests so that:

- The StorageClass uses the Minikube host-path provisioner
- Its binding mode is `WaitForFirstConsumer`
- The PVC requests that class
- The Pod consumes the claim at `/data`
- The Minikube storage provisioner can read the Node selected for the Pod

## Run

```bash
cd exercises/05-wait-for-first-consumer
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/rbac.yaml
kubectl apply -f exercise/storageclass.yaml
kubectl apply -f exercise/pvc.yaml
kubectl get pvc delayed-data -n pv-lab-05
```

At this point the PVC should remain `Pending`. The claim is waiting for Kubernetes to learn where its first consumer will run.

Now create the consumer:

```bash
kubectl apply -f exercise/pod.yaml
kubectl wait --for=condition=Ready pod/delayed-consumer -n pv-lab-05 --timeout=120s
kubectl get pvc -n pv-lab-05
kubectl get pv
```

## Progressive hints

1. The Minikube provisioner is normally `k8s.io/minikube-hostpath`.
2. The binding mode is written exactly as `WaitForFirstConsumer`.
3. `storageClassName` must equal the StorageClass metadata.name.
4. The provisioner's ServiceAccount is `storage-provisioner` in the `kube-system` namespace.

## Expected result

Before the Pod exists:

```text
NAME           STATUS
 delayed-data  Pending
```

After the Pod is scheduled, the PVC becomes `Bound` and the Pod becomes `Running`.

## Common errors

### PVC becomes `Bound` immediately

Confirm the PVC actually references `pv-lab-delayed` and inspect the class:

```bash
kubectl get sc pv-lab-delayed -o yaml
```

### Provisioner is different on your cluster

Find the provisioner used by your default class:

```bash
kubectl get sc -o custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner
```

Replace the Minikube-specific value in the exercise.

### Pod remains `Pending`

```bash
kubectl describe pod delayed-consumer -n pv-lab-05
kubectl describe pvc delayed-data -n pv-lab-05
```

If the PVC events contain the following error, confirm that `exercise/rbac.yaml` was applied:

```text
failed to get target node: nodes "minikube" is forbidden
```

Read this message from right to left:

- `nodes "minikube"` is the resource the provisioner tried to read.
- `cannot get resource "nodes"` means the missing action is the RBAC `get` verb.
- `system:serviceaccount:kube-system:storage-provisioner` is the identity that needs the permission.

You can verify the permission directly:

```bash
kubectl auth can-i get nodes \
  --as=system:serviceaccount:kube-system:storage-provisioner
```

The expected answer is `yes`. Once the permission exists, the provisioner retries automatically; the PVC should become `Bound` without recreating it.

## Solution

Apply the files under `solution/` in the same order.

## Cleanup

```bash
kubectl delete namespace pv-lab-05
kubectl delete storageclass pv-lab-delayed
kubectl delete -f exercise/rbac.yaml
```
