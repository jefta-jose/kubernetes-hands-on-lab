# Exercise 08 — Understand `hostPath` and Node Locality

## Concept

A `hostPath` volume mounts a path from the Kubernetes worker node into a container.

This is different from mounting a directory from your Windows or Linux host into a Docker container. On Docker Desktop, the Kubernetes node runs inside a managed virtual machine, so the path belongs to that Kubernetes node.

`hostPath` is:

- Node-specific
- Difficult to move safely
- Powerful enough to expose sensitive node files
- Normally reserved for trusted system workloads

## Safety boundary

This exercise uses only:

```text
/tmp/kubernetes-volumes-lab
```

Do not replace it with `/`, `/etc`, `/var/lib/kubelet`, or a container runtime socket.

## Task

Complete both Pod manifests so that:

- The writer creates a marker file under a node directory.
- The reader mounts the same node directory read-only.
- The type is `DirectoryOrCreate`.
- Both Pods use `/host-data` inside their containers.

This exercise works most predictably on a single-node local cluster.

## Run

```bash
kubectl get nodes
```

If you have more than one node, the Pods may land on different nodes and not see the same data.

Complete and apply:

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /tmp/08
cp exercise/writer.yaml /tmp/08/writer.yaml
cp exercise/reader.yaml /tmp/08/reader.yaml
nano /tmp/08/writer.yaml
nano /tmp/08/reader.yaml
kubectl apply --dry-run=client -f /tmp/08/
kubectl apply -f /tmp/08/
kubectl wait --for=condition=Ready pod/hostpath-writer -n volumes-lab --timeout=90s
kubectl wait --for=condition=Ready pod/hostpath-reader -n volumes-lab --timeout=90s
```

## Test

Check node placement:

```bash
kubectl get pod hostpath-writer hostpath-reader -n volumes-lab -o wide
```

Read the marker from the reader:

```bash
kubectl exec -n volumes-lab hostpath-reader -- cat /host-data/marker.txt
```

## Progressive hints

<details>
<summary>Hint 1</summary>

The volume type is `hostPath`.

</details>

<details>
<summary>Hint 2</summary>

The node path is `/tmp/kubernetes-volumes-lab`.

</details>

<details>
<summary>Hint 3</summary>

Use `DirectoryOrCreate` so kubelet creates the directory when it is missing.

</details>

## Expected result

On a single-node cluster, the reader sees the file created by the writer.

The demonstration proves that both Pods access the same **node-local** directory, not portable application storage.

## Common errors

### Reader cannot find the marker

The Pods may be on different nodes.

```bash
kubectl get pods -n volumes-lab -o wide
```

### Pod fails with a host path type error

Check that `type` is exactly `DirectoryOrCreate`.

### You expected to see the directory on Windows

The path belongs to the Kubernetes node VM used by Docker Desktop.

## Cleanup

```bash
kubectl delete pod hostpath-writer hostpath-reader -n volumes-lab --ignore-not-found
```

The node directory may remain after Pod deletion. This is another reason `hostPath` requires deliberate lifecycle management.
