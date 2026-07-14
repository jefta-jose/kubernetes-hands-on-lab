# Exercise 02 — Share Files Between Containers

## Concept

Volumes are defined at Pod level and can be mounted into more than one container.

Each container can mount the same volume at a different path. One container can receive read-write access while another receives read-only access.

## Task

Complete the Pod so that:

- `content-writer` writes HTML into a shared `emptyDir`.
- `nginx` serves the same files.
- Nginx mounts the volume read-only.
- The shared volume is named `web-content`.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
cp exercise/pod.yaml /tmp/02-pod.yaml
nano /tmp/02-pod.yaml
kubectl apply --dry-run=client -f /tmp/02-pod.yaml
kubectl apply -f /tmp/02-pod.yaml
kubectl wait --for=condition=Ready pod/shared-volume-demo -n volumes-lab --timeout=90s
```

## Test

Compare the same file from both containers:

```bash
kubectl exec -n volumes-lab shared-volume-demo -c content-writer -- cat /writer/index.html
kubectl exec -n volumes-lab shared-volume-demo -c nginx -- cat /usr/share/nginx/html/index.html
```

Start port forwarding:

```bash
kubectl port-forward -n volumes-lab pod/shared-volume-demo 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
sleep 6
curl http://localhost:8080
```

The timestamp should change.

## Progressive hints

<details>
<summary>Hint 1</summary>

Both `volumeMounts` entries reference the same Pod-level volume name.

</details>

<details>
<summary>Hint 2</summary>

The writer path is `/writer`.

</details>

<details>
<summary>Hint 3</summary>

The standard Nginx document root is `/usr/share/nginx/html`.

</details>

## Expected result

- Both containers see the same `index.html`.
- The writer can modify the file.
- Nginx serves the generated page.
- The Nginx mount is read-only.

## Common errors

### Nginx returns 403 or 404

The volume is probably mounted at the wrong Nginx directory.

### The writer and Nginx show different files

They may reference different volume names.

### The Pod remains at `1/2 Running`

Inspect both containers:

```bash
kubectl describe pod shared-volume-demo -n volumes-lab
kubectl logs shared-volume-demo -n volumes-lab -c content-writer
kubectl logs shared-volume-demo -n volumes-lab -c nginx
```

## Cleanup

```bash
kubectl delete pod shared-volume-demo -n volumes-lab --ignore-not-found
```
