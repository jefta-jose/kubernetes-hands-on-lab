# Exercise 01 — Direct Pod Networking

## Concept

Every Pod receives its own IP address. Pods can communicate directly across
the cluster network when they know each other's IP addresses.

The weakness is lifecycle coupling: a replacement Pod can receive a different
IP. This exercise intentionally uses a Pod IP directly so you can see why
Services are needed later.

## Task

Complete `exercise.yaml` so that:

- The server Pod is named `echo-server`
- The server label is `app: echo`
- The client Pod is named `network-client`
- The client uses the `curlimages/curl:8.10.1` image

## Run

```bash
cp exercise.yaml my-answer.yaml
# Replace every blank.
kubectl apply --dry-run=client -f my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl wait --for=condition=Ready pod/echo-server -n service-lab-pods --timeout=120s
kubectl wait --for=condition=Ready pod/network-client -n service-lab-pods --timeout=120s
```

Find the server Pod IP:

```bash
SERVER_IP=$(kubectl get pod echo-server -n service-lab-pods -o jsonpath='{.status.podIP}')
echo "$SERVER_IP"
```

Connect directly:

```bash
kubectl exec -n service-lab-pods network-client -- \
  curl -s "http://$SERVER_IP:5678"
```

Automated test:

```bash
./test.sh
```

## Progressive hints

1. `metadata.name` identifies an object inside its namespace.
2. Labels are arbitrary key/value metadata used later by selectors.
3. The client image must contain the `curl` command.
4. The server listens on port `5678`.

## Expected result

```text
hello-from-pod
```

## Common errors

### Pod remains Pending

```bash
kubectl describe pod -n service-lab-pods echo-server
```

Check whether the image can be pulled and whether the cluster has a ready
node.

### Connection refused

Confirm the server is ready and the command includes port `5678`:

```bash
kubectl logs -n service-lab-pods echo-server
kubectl get pod -n service-lab-pods echo-server -o wide
```

### The IP changes after recreation

That is expected. Delete and recreate the server, then inspect its new IP:

```bash
kubectl delete pod echo-server -n service-lab-pods
kubectl apply -f my-answer.yaml
kubectl get pod echo-server -n service-lab-pods -o wide
```

## Clean up

```bash
./cleanup.sh
```
