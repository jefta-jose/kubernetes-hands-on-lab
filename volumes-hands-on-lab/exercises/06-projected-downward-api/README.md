# Exercise 06 — Combine Config, Secrets, and Pod Metadata

## Concept

A projected volume combines several sources into one directory.

This exercise combines:

- A ConfigMap
- A Secret
- Downward API fields

The container receives runtime context without calling the Kubernetes API.

## Task

Complete the manifests so that the projected volume exposes:

```text
/context/application-name
/context/api-token
/context/pod-name
/context/namespace
/context/labels
```

The Pod name, namespace, and labels must come from the Pod's own metadata.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /tmp/06
cp exercise/configmap.yaml /tmp/06/configmap.yaml
cp exercise/secret.yaml /tmp/06/secret.yaml
cp exercise/pod.yaml /tmp/06/pod.yaml
nano /tmp/06/configmap.yaml
nano /tmp/06/secret.yaml
nano /tmp/06/pod.yaml
kubectl apply --dry-run=client -f /tmp/06/
kubectl apply -f /tmp/06/
kubectl wait --for=condition=Ready pod/projected-volume-demo -n volumes-lab --timeout=90s
```

## Test

List the projected files:

```bash
kubectl exec -n volumes-lab projected-volume-demo -- find /context -maxdepth 1 -type f -o -type l
```

Read every file:

```bash
kubectl exec -n volumes-lab projected-volume-demo -- sh -c '
  for file in /context/*; do
    echo "=== ${file} ==="
    cat "${file}"
    echo
  done
'
```

## Progressive hints

<details>
<summary>Hint 1</summary>

The combined volume type is `projected`.

</details>

<details>
<summary>Hint 2</summary>

Downward API metadata uses `fieldRef.fieldPath`.

</details>

<details>
<summary>Hint 3</summary>

Useful field paths are `metadata.name`, `metadata.namespace`, and `metadata.labels`.

</details>

## Expected result

The container can read configuration, a Secret value, and its own Pod metadata from one directory.

## Common errors

### A projected file is missing

Check its `path`, source name, and source key.

### Pod remains in `ContainerCreating`

One of the referenced ConfigMaps or Secrets may be absent.

```bash
kubectl describe pod projected-volume-demo -n volumes-lab
```

### Labels file formatting looks unusual

Kubernetes renders labels as key-value lines. That is expected.

## Cleanup

```bash
kubectl delete pod projected-volume-demo -n volumes-lab --ignore-not-found
kubectl delete configmap projected-config -n volumes-lab --ignore-not-found
kubectl delete secret projected-secret -n volumes-lab --ignore-not-found
```
