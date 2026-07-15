# Exercise 02 — Stable Access with ClusterIP

## Concept

A ClusterIP Service provides a stable virtual IP and DNS name inside the
cluster. Its selector identifies the Pods that receive traffic.

A Deployment may replace Pods, but clients keep using the same Service name.

## Task

Complete the manifest so that:

- The Deployment runs `3` replicas
- Pods use the label `app: quote`
- The Service is named `quote`
- The Service selector matches `app: quote`
- The Service exposes port `80`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply --dry-run=client -f my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/quote -n service-lab-clusterip
```

Inspect the stable Service and changing Pods:

```bash
kubectl get svc quote -n service-lab-clusterip
kubectl get pods -n service-lab-clusterip -o wide
kubectl get endpointslices -n service-lab-clusterip
```

Test from the client:

```bash
kubectl exec -n service-lab-clusterip service-client -- \
  curl -s http://quote
```

Run several requests:

```bash
for i in 1 2 3 4 5; do
  kubectl exec -n service-lab-clusterip service-client -- curl -s http://quote
done
```

## Progressive hints

1. A selector must exactly match Pod labels.
2. ClusterIP is the default Service type.
3. The server container listens on port `5678`.
4. The Service can expose port `80` while forwarding elsewhere.

## Expected result

Every request returns:

```text
quote-service
```

`kubectl get endpointslices` should show three ready backend addresses.

## Common errors

### Service has no endpoints

```bash
kubectl describe svc quote -n service-lab-clusterip
kubectl get pods -n service-lab-clusterip --show-labels
```

Compare the Service selector with the Pod labels.

### DNS name does not resolve

Confirm the client and Service are in the same namespace:

```bash
kubectl get pod,svc -n service-lab-clusterip
```

### Request times out

Check `targetPort` and the container's listening port.

## Clean up

```bash
./cleanup.sh
```
