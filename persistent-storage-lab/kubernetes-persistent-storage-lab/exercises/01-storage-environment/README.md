# Exercise 01 — Inspect the Storage Environment

## Concept

Before creating claims, inspect the storage capabilities already available in the cluster.

A StorageClass describes how storage is provisioned. A PersistentVolume represents allocated storage. A CSI driver connects Kubernetes to a storage platform.

## Task

Complete `exercise/inspect-storage.sh` so that it lists:

1. StorageClasses
2. PersistentVolumes
3. Registered CSI drivers
4. The default StorageClass name and provisioner

## Run

```bash
cd exercises/01-storage-environment
bash exercise/inspect-storage.sh
```

## Progressive hints

1. StorageClass has the shorthand `sc`.
2. PersistentVolume has the shorthand `pv`.
3. CSI drivers are listed with the plural resource name `csidriver`.
4. The default class has the annotation `storageclass.kubernetes.io/is-default-class=true`.

## Expected result

You should see at least one StorageClass. On the reference Minikube setup, the default class is normally `standard` and its provisioner is `k8s.io/minikube-hostpath`.

The PV list may be empty because no storage has been provisioned yet.

## Common errors

### `The connection to the server was refused`

Start Minikube:

```bash
minikube start --driver=docker
```

### No default StorageClass

Inspect all classes:

```bash
kubectl get sc -o yaml
```

A later dynamic-provisioning exercise requires a default or explicitly selected class.

### No CSI drivers are listed

Some local provisioners are not CSI-based. This does not prevent the first dynamic PVC exercises from working, but CSI-only features such as snapshots or `ReadWriteOncePod` may not be available.

## Solution

```bash
bash solution/inspect-storage.sh
```

## Cleanup

This exercise creates no resources.
