# Exercise 01 — Preserve Data Across a Container Restart

## Concept

Files written only to a container filesystem disappear when Kubernetes replaces that container.

An `emptyDir` volume belongs to the Pod rather than to one container instance. It survives a container restart while the Pod remains alive.

It does **not** survive Pod deletion.

## Task

Complete `exercise/pod.yaml` so that:

- The Pod defines an `emptyDir` volume named `counter-data`.
- The container mounts it at `/data`.
- The application continuously increments a counter stored in `/data/counter.txt`.

## Files

```text
exercise/pod.yaml
solution/pod.yaml
```

## Run

Create the lab namespace:

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
```

Copy and complete the exercise:

```bash
cp exercise/pod.yaml /tmp/01-pod.yaml
nano /tmp/01-pod.yaml
```

Check remaining blanks:

```bash
grep -n "________" /tmp/01-pod.yaml
```

Validate and apply:

```bash
kubectl apply --dry-run=client -f /tmp/01-pod.yaml
kubectl apply -f /tmp/01-pod.yaml
kubectl wait --for=condition=Ready pod/volume-restart-demo -n volumes-lab --timeout=90s
```

## Test

Read the counter:

```bash
kubectl exec -n volumes-lab volume-restart-demo -- cat /data/counter.txt
```

Wait a few seconds and read it again:

```bash
sleep 6
kubectl exec -n volumes-lab volume-restart-demo -- cat /data/counter.txt
```

Record the Pod UID and restart count:

```bash
kubectl get pod volume-restart-demo -n volumes-lab \
  -o custom-columns=UID:.metadata.uid,RESTARTS:.status.containerStatuses[0].restartCount
```

Kill PID 1 inside the container:

```bash
kubectl exec -n volumes-lab volume-restart-demo -- kill 1 || true
```

Wait for the replacement container:

```bash
kubectl wait --for=condition=Ready pod/volume-restart-demo -n volumes-lab --timeout=90s
kubectl get pod volume-restart-demo -n volumes-lab
```

Read the counter again:

```bash
kubectl exec -n volumes-lab volume-restart-demo -- cat /data/counter.txt
```

The value should continue increasing rather than returning to `0`.

## Progressive hints

<details>
<summary>Hint 1</summary>

The volume type is named after a directory that starts empty.

</details>

<details>
<summary>Hint 2</summary>

The volume definition belongs under `spec.volumes`.

</details>

<details>
<summary>Hint 3</summary>

The `volumeMounts[].name` value must exactly match the `volumes[].name` value.

</details>

## Expected result

- The container restarts.
- The Pod UID remains unchanged.
- The restart count increases.
- `/data/counter.txt` keeps its previous value and continues increasing.

## Common errors

### `volumeMounts` refers to an unknown volume

The mount name and volume name do not match.

Check:

```bash
kubectl describe pod volume-restart-demo -n volumes-lab
```

### The counter resets after killing the container

The application is probably writing outside the mounted path.

Confirm:

```bash
kubectl exec -n volumes-lab volume-restart-demo -- mount | grep /data
```

### `kill 1` returns a non-zero status

The connection can close as soon as the process dies. This is expected. The `|| true` prevents the shell from treating it as a lab failure.

## Cleanup

```bash
kubectl delete pod volume-restart-demo -n volumes-lab --ignore-not-found
```
