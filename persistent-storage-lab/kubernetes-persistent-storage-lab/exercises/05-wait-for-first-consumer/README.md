# Exercise 05 — Delay Provisioning with WaitForFirstConsumer

## Concept

A StorageClass controls how and when storage is provisioned.

`Immediate` provisions storage as soon as the PVC exists. `WaitForFirstConsumer` delays provisioning and binding until a Pod references the claim. This allows Kubernetes to coordinate storage topology with Pod scheduling.

## Task

Complete the manifests so that:

- The StorageClass uses the Minikube host-path provisioner
- Its binding mode is `WaitForFirstConsumer`
- The PVC requests that class
- The Pod consumes the claim at `/data`

## Run

```bash
cd exercises/05-wait-for-first-consumer
kubectl apply -f exercise/namespace.yaml
kubectl apply -f exercise/storageclass.yaml
kubectl apply -f exercise/pvc.yaml
kubectl get pvc delayed-data -n pv-lab-05
```

Before creating the Pod, the PVC should normally remain `Pending`.

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

## Solution

Apply the files under `solution/` in the same order.

## Cleanup

```bash
kubectl delete namespace pv-lab-05
kubectl delete storageclass pv-lab-delayed
```
