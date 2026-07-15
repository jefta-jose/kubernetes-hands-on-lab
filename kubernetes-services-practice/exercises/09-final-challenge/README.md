# Exercise 09 — Final Challenge

## Scenario

You are exposing a small Quote API.

The workload must:

- Run three replicas
- Use a stable internal Service
- Be discoverable through DNS
- Exclude unready Pods from traffic
- Offer a headless Service for direct endpoint discovery
- Be externally reachable through NodePort
- Keep Service and Pod ports decoupled with a named target port

## Task

Complete `exercise.yaml`.

You must determine values for:

- Replica count
- Deployment selector and Pod labels
- Named container port
- Readiness probe port
- ClusterIP Service selector, port, and target port
- Headless Service configuration
- NodePort Service configuration
- Client DNS target

There are more blanks than earlier exercises, but every value has appeared in
a previous lab.

## Run

```bash
cp exercise.yaml my-answer.yaml
grep -n '________' my-answer.yaml
kubectl apply --dry-run=client -f my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/quote-api -n service-lab-final
kubectl wait --for=condition=Ready pod/final-client \
  -n service-lab-final --timeout=120s
```

## Test internal stable access

```bash
kubectl exec -n service-lab-final final-client -- \
  curl -s http://quote-api
```

## Test Service DNS

```bash
kubectl exec -n service-lab-final final-client -- \
  nslookup quote-api.service-lab-final.svc.cluster.local
```

## Inspect EndpointSlices

```bash
kubectl get endpointslices -n service-lab-final
kubectl describe endpointslice -n service-lab-final
```

## Test headless discovery

```bash
kubectl exec -n service-lab-final final-client -- \
  nslookup quote-api-headless
```

The result should contain the three Pod IP addresses.

## Test external access

With the included kind cluster:

```bash
curl http://localhost:8081
```

The kind configuration maps host port `8081` to NodePort `30081`.

## Progressive hints

1. Use one consistent label value across the Deployment selector, Pod template,
   and all Service selectors.
2. The application listens on `8080`.
3. Name the container port `http`.
4. The stable ClusterIP Service should expose port `80`.
5. A headless Service uses `clusterIP: None`.
6. The external Service type is `NodePort`.
7. Use node port `30081`.
8. The client can use the short DNS name because it shares the namespace.

## Expected result

Every HTTP request returns:

```text
stable-networking-for-ephemeral-pods
```

The normal Service has one ClusterIP. The headless Service has no ClusterIP
and resolves to Pod addresses. The NodePort Service exposes the same ready
backends externally.

## Common errors

### Deployment selector is invalid

A Deployment's selector must match its Pod template labels and is immutable
after creation. Delete the namespace and recreate the exercise after fixing it.

### Services have zero endpoints

Compare every selector with the Pod labels:

```bash
kubectl get pods -n service-lab-final --show-labels
kubectl get svc -n service-lab-final -o yaml
```

### Pods are running but not ready

Inspect readiness events:

```bash
kubectl describe pod -n service-lab-final -l app=quote-api
```

### Headless DNS returns fewer than three addresses

Wait for all replicas to become ready:

```bash
kubectl rollout status deployment/quote-api -n service-lab-final
kubectl get pods -n service-lab-final
```

### localhost:8081 is unavailable

Use the included kind cluster configuration or test through the node's
reachable address and NodePort `30081`.

## Automated verification

```bash
./test.sh
```

## Clean up

```bash
./cleanup.sh
```
