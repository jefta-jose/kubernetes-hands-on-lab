# Kubernetes Persistent Storage Hands-On Lab

A fill-in-the-blank project for practising Kubernetes persistent storage locally.

The lab progresses from inspecting the storage environment to dynamic provisioning, Pod mounts, data persistence, delayed binding, static provisioning, reclaim policies, generic ephemeral volumes, and a final StatefulSet challenge.

## Learning format

Important values are replaced with:

```text
________
```

Complete the blanks before applying an exercise. Standard boilerplate remains in place so that each task focuses on the concept being taught.

Every exercise contains:

- A concept explanation
- A concrete task
- Incomplete files
- Run and test commands
- Progressive hints
- Expected results
- Troubleshooting guidance
- Completed solutions

## Target environment

The project is designed and validated for a **single-node Minikube cluster** using the Docker driver.

Why Minikube is the reference environment:

- It provides a predictable default `standard` StorageClass.
- Its default provisioner is normally `k8s.io/minikube-hostpath`.
- Node-local storage exercises can use the known `minikube` node.
- Everything runs on a local workstation.

Docker Desktop Kubernetes, kind, k3d, and other clusters can run most exercises, but exercises 05, 06, and 08 may require changing the provisioner or node name.

## Prerequisites

Install:

- Docker
- `kubectl`
- Minikube
- Python 3 with PyYAML for local file validation

Start the cluster:

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

Confirm connectivity:

```bash
kubectl get nodes
kubectl get storageclass
```

Run the project preflight check:

```bash
make preflight
```

Validate all project files:

```bash
make validate
```

## Recommended workflow

For each exercise:

1. Read its `README.md`.
2. Copy or edit the files under `exercise/`.
3. Replace each `________` with the correct value.
4. Run the provided commands.
5. Troubleshoot before opening the solution.
6. Compare your work with `solution/`.
7. Clean up before moving to the next exercise.

## Exercise map

| Exercise | Topic | Main skill |
|---|---|---|
| 01 | Storage environment | Inspect StorageClasses, PVs, and CSI drivers |
| 02 | Dynamic PVC | Request storage using a PVC |
| 03 | Pod mount | Mount a claim into a container |
| 04 | Persistence | Prove data survives Pod replacement |
| 05 | Delayed binding | Use `WaitForFirstConsumer` |
| 06 | Static PV | Bind node-local storage and observe `Retain` |
| 07 | Generic ephemeral volume | Tie a PVC-backed volume to a Pod lifecycle |
| 08 | Final challenge | Combine StorageClass, StatefulSet, PVC, and persistence |

## Useful storage inspection commands

```bash
kubectl get sc
kubectl get pvc -A
kubectl get pv
kubectl get csidriver
kubectl describe pvc <claim> -n <namespace>
kubectl describe pv <volume>
kubectl describe pod <pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

Show the current lab storage state:

```bash
bash scripts/show-storage-state.sh
```

## Cleaning everything

```bash
make clean
```

The cleanup script removes all lab namespaces, StorageClasses, PersistentVolumes, and the Minikube node-local directory used by exercise 06.

## Important production warning

This lab intentionally deletes claims, volumes, and local data. Never reuse these cleanup commands against production resources without checking names, namespaces, reclaim policies, and backups.
