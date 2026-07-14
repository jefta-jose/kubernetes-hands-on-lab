# Exercise 05 — Mount Secrets with Restricted Permissions

## Concept

Secret volumes expose decoded Secret values as files.

Sensitive files should normally be:

- Mounted read-only
- Visible only to the required container
- Protected with restrictive file modes
- Readable by the application's actual UID or GID

`fsGroup` can make a mounted volume readable by a non-root process through group ownership.

## Task

Complete the manifests so that:

- The Secret is named `application-credentials`.
- The Secret contains `username` and `password`.
- The files use mode `0440`.
- The Pod filesystem group is `101`.
- The non-root container runs as UID and GID `101`.
- The Secret is mounted read-only at `/credentials`.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /tmp/05
cp exercise/secret.yaml /tmp/05/secret.yaml
cp exercise/pod.yaml /tmp/05/pod.yaml
nano /tmp/05/secret.yaml
nano /tmp/05/pod.yaml
kubectl apply --dry-run=client -f /tmp/05/
kubectl apply -f /tmp/05/
kubectl wait --for=condition=Ready pod/secret-volume-demo -n volumes-lab --timeout=90s
```

## Test

Read the files:

```bash
kubectl exec -n volumes-lab secret-volume-demo -- cat /credentials/username
kubectl exec -n volumes-lab secret-volume-demo -- cat /credentials/password
```

Inspect process identity:

```bash
kubectl exec -n volumes-lab secret-volume-demo -- id
```

Inspect target file permissions:

```bash
kubectl exec -n volumes-lab secret-volume-demo -- ls -lL /credentials
```

## Progressive hints

<details>
<summary>Hint 1</summary>

Use `stringData` in the Secret so you can write plain values in the manifest. Kubernetes converts them into Secret data.

</details>

<details>
<summary>Hint 2</summary>

The octal mode that permits owner and group read access is `0440`.

</details>

<details>
<summary>Hint 3</summary>

`fsGroup` is configured under the Pod-level `securityContext`.

</details>

## Expected result

- The process runs as UID/GID `101`.
- The Secret files are readable.
- The mount is read-only.
- The displayed target permissions are restrictive.

## Common errors

### Container exits with `Permission denied`

The file mode, `fsGroup`, or process GID is wrong.

```bash
kubectl logs secret-volume-demo -n volumes-lab
kubectl describe pod secret-volume-demo -n volumes-lab
```

### `ls -l` shows symbolic links as `rwxrwxrwx`

Secret and ConfigMap projected files use symbolic links.

Use:

```bash
kubectl exec -n volumes-lab secret-volume-demo -- ls -lL /credentials
```

### Pod does not start because the Secret is missing

Apply `secret.yaml` before or together with `pod.yaml`.

## Cleanup

```bash
kubectl delete pod secret-volume-demo -n volumes-lab --ignore-not-found
kubectl delete secret application-credentials -n volumes-lab --ignore-not-found
```
