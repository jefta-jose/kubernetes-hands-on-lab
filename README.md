# Kubernetes Volumes Hands-On Lab

A progressive, fill-in-the-blank project for practising Kubernetes storage, configuration, secrets, metadata injection, and data sharing inside Pods.

The exercises are based on these core ideas:

- A container filesystem is ephemeral.
- A Pod-level volume can survive a container restart.
- An `emptyDir` volume does not survive Pod deletion.
- Multiple containers in the same Pod can mount the same volume.
- Init containers can prepare data before application containers start.
- ConfigMaps and Secrets can be mounted as files.
- The Downward API can expose Pod metadata as files.
- Projected volumes can combine several configuration sources.
- PersistentVolumeClaims separate storage lifetime from Pod lifetime.
- `hostPath` exposes node-local files and must be treated as privileged access.

## Learning format

Important values in each exercise file are replaced with:

```text
________
```

Your task is to replace each blank with the correct value.

Only concept-relevant values are blanked. Boilerplate fields remain in place so that you can focus on the topic being taught.

Every exercise contains:

1. Concept explanation
2. Task
3. Incomplete manifest
4. Run and test commands
5. Progressive hints
6. Expected result
7. Troubleshooting guidance

## Project structure

```text
kubernetes-volumes-hands-on-lab/
├── README.md
├── scripts/
│   ├── check-prerequisites.sh
│   └── cleanup-all.sh
└── exercises/
    ├── 01-emptydir-container-restart/
    ├── 02-shared-volume/
    ├── 03-init-container/
    ├── 04-configmap-volume/
    ├── 05-secret-volume-permissions/
    ├── 06-projected-downward-api/
    ├── 07-persistent-volume-claim/
    ├── 08-hostpath-safety/
    └── 09-final-challenge/
```

## Prerequisites

Recommended local setup:

- Docker Desktop with Kubernetes enabled
- `kubectl`
- Bash through WSL, Git Bash, Linux, or macOS
- `curl`

Check your environment:

```bash
./scripts/check-prerequisites.sh
```

Confirm your cluster:

```bash
kubectl cluster-info
kubectl get nodes
```

The exercises use the namespace:

```text
volumes-lab
```

Create it once:

```bash
kubectl create namespace volumes-lab
```

If it already exists, Kubernetes will report `AlreadyExists`; that is safe to ignore.

## Recommended workflow

Work through one exercise at a time.

```bash
cd exercises/01-emptydir-container-restart
cat README.md
cp exercise/pod.yaml /tmp/pod.yaml
```

Edit `/tmp/pod.yaml` and replace every `________`.

Check whether blanks remain:

```bash
grep -R "________" /tmp/pod.yaml
```

Validate the completed manifest without creating resources:

```bash
kubectl apply --dry-run=client -f /tmp/pod.yaml
```

Apply it:

```bash
kubectl apply -f /tmp/pod.yaml
```

## Clean up everything

```bash
./scripts/cleanup-all.sh
```

You can also remove the namespace directly:

```bash
kubectl delete namespace volumes-lab
```

Deleting the namespace removes namespaced Pods, ConfigMaps, Secrets, Services, Deployments, and PVCs created by this project.

## Exercise order

| Exercise | Main concept | Difficulty |
|---|---|---|
| 01 | `emptyDir` and container restart | Beginner |
| 02 | Sharing a volume between containers | Beginner |
| 03 | Initializing a volume with an init container | Beginner |
| 04 | ConfigMap files and update behavior | Intermediate |
| 05 | Secret files, permissions, and `fsGroup` | Intermediate |
| 06 | Projected volume and Downward API | Intermediate |
| 07 | PersistentVolumeClaim lifecycle | Advanced |
| 08 | `hostPath` security and node locality | Advanced |
| 09 | Combined production-style challenge | Final challenge |

## Important safety note

Exercise 08 demonstrates `hostPath`.

`hostPath` can expose the node filesystem to a container. The exercise deliberately mounts only a temporary lab directory, but the capability itself is powerful and dangerous.

Never casually mount paths such as:

```text
/
/etc
/var/lib/kubelet
/var/run/docker.sock
/run/containerd/containerd.sock
```

In production, restrict `hostPath` through policy and use it only for trusted system workloads.
