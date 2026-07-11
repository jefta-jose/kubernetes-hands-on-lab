# Exercise 04 — Mount ConfigMap Entries as Files

## Concept

A ConfigMap volume exposes ConfigMap keys as files.

This is useful for multiline configuration that does not fit naturally into environment variables.

When the full ConfigMap volume is mounted, Kubernetes can refresh the files after the ConfigMap changes. The application must still reload or reread the file.

## Task

Complete both manifests so that:

- The ConfigMap is named `web-config`.
- The Pod mounts it as a volume named `config`.
- Only the key `message.txt` is projected.
- The file is mounted under `/config`.
- The container prints the file every five seconds.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /tmp/04
cp exercise/configmap.yaml /tmp/04/configmap.yaml
cp exercise/pod.yaml /tmp/04/pod.yaml
nano /tmp/04/configmap.yaml
nano /tmp/04/pod.yaml
kubectl apply --dry-run=client -f /tmp/04/
kubectl apply -f /tmp/04/
kubectl wait --for=condition=Ready pod/configmap-volume-demo -n volumes-lab --timeout=90s
```

## Test

Read the mounted file:

```bash
kubectl exec -n volumes-lab configmap-volume-demo -- cat /config/message.txt
```

Follow logs:

```bash
kubectl logs -n volumes-lab configmap-volume-demo -f
```

In another terminal, update the ConfigMap:

```bash
kubectl patch configmap web-config -n volumes-lab \
  --type merge \
  -p '{"data":{"message.txt":"Updated configuration from Kubernetes\n"}}'
```

Wait up to roughly a minute and inspect the mounted file again:

```bash
kubectl exec -n volumes-lab configmap-volume-demo -- cat /config/message.txt
```

## `subPath` comparison

The solution folder also contains `pod-subpath.yaml`.

Apply the comparison Pod:

```bash
kubectl apply -f solution/pod-subpath.yaml
kubectl wait --for=condition=Ready pod/configmap-subpath-demo -n volumes-lab --timeout=90s
```

The file is mounted directly at `/app/message.txt` using `subPath`.

Update the ConfigMap again. The subPath-mounted file will not receive normal live updates.

## Progressive hints

<details>
<summary>Hint 1</summary>

The volume type field is `configMap`.

</details>

<details>
<summary>Hint 2</summary>

The ConfigMap reference uses the field `name`.

</details>

<details>
<summary>Hint 3</summary>

The `items` list maps a ConfigMap `key` to a volume `path`.

</details>

## Expected result

- `/config/message.txt` contains the ConfigMap value.
- Updating the ConfigMap eventually updates the full-volume mount.
- The `subPath` variant demonstrates why single-file mounts behave differently.

## Common errors

### Pod is stuck in `ContainerCreating`

The ConfigMap may not exist or its name may not match.

```bash
kubectl get configmap -n volumes-lab
kubectl describe pod configmap-volume-demo -n volumes-lab
```

### File does not update immediately

Projected volume refresh is asynchronous. Wait and test again.

### File never updates in the `subPath` variant

That is expected behavior.

## Cleanup

```bash
kubectl delete pod configmap-volume-demo configmap-subpath-demo -n volumes-lab --ignore-not-found
kubectl delete configmap web-config -n volumes-lab --ignore-not-found
```
