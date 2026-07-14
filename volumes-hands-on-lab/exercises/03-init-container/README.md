# Exercise 03 — Initialize a Volume Before the Application Starts

## Concept

Init containers run before regular containers.

They are useful for preparing files, generating configuration, downloading artifacts, or creating directory structures required by the application.

A common pattern is:

```text
init container -> shared volume -> application container
```

## Task

Complete the Pod so that:

- An init container writes `/work/index.html`.
- Nginx starts only after the init container completes.
- Nginx mounts the same volume at its document root.
- The Nginx mount is read-only.

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
cp exercise/pod.yaml /tmp/03-pod.yaml
nano /tmp/03-pod.yaml
kubectl apply --dry-run=client -f /tmp/03-pod.yaml
kubectl apply -f /tmp/03-pod.yaml
kubectl wait --for=condition=Ready pod/init-volume-demo -n volumes-lab --timeout=90s
```

## Test

Inspect init container status:

```bash
kubectl get pod init-volume-demo -n volumes-lab \
  -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}{"\n"}'
```

Expected:

```text
Completed
```

Read the generated file:

```bash
kubectl exec -n volumes-lab init-volume-demo -c nginx -- cat /usr/share/nginx/html/index.html
```

Port-forward and test:

```bash
kubectl port-forward -n volumes-lab pod/init-volume-demo 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

## Progressive hints

<details>
<summary>Hint 1</summary>

The init container section is named `initContainers`.

</details>

<details>
<summary>Hint 2</summary>

Both containers use the volume named `site`.

</details>

<details>
<summary>Hint 3</summary>

The init container mounts the volume at `/work`; Nginx mounts it at `/usr/share/nginx/html`.

</details>

## Expected result

- The init container terminates with reason `Completed`.
- Nginx starts afterward.
- The generated HTML file is available through Nginx.

## Common errors

### Pod status is `Init:CrashLoopBackOff`

Inspect the init container:

```bash
kubectl logs init-volume-demo -n volumes-lab -c site-builder
kubectl describe pod init-volume-demo -n volumes-lab
```

### Nginx starts but the file is missing

Check whether the init and application containers reference the same volume name.

## Cleanup

```bash
kubectl delete pod init-volume-demo -n volumes-lab --ignore-not-found
```
