# Exercise 07 — Headless Services

## Concept

A normal ClusterIP Service DNS name resolves to one virtual Service IP. A
headless Service has `clusterIP: None`. Its DNS name resolves directly to the
backend endpoint addresses.

Like a normal ClusterIP Service, this headless Service is intended for
internal cluster communication. However, "headless" does not mean
"internal-only": it specifically means that the Service has no virtual IP and
does not provide Kubernetes proxying or load balancing. The Service still
provides a stable internal DNS name and automatically discovers matching Pods.

This is useful when clients need endpoint awareness, direct Pod connections,
peer discovery, or client-side load balancing.

## Task

Complete the manifest so that:

- The Service is named `peer-api`
- It is headless with `clusterIP: None`
- It selects `app: peer-api`
- It forwards to the named target port `http`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/peer-api -n service-lab-headless
kubectl wait --for=condition=Ready pod/dns-client \
  -n service-lab-headless --timeout=120s
```

Inspect the Service:

```bash
kubectl get svc peer-api -n service-lab-headless
```

Resolve its records:

```bash
kubectl exec -n service-lab-headless dns-client -- nslookup peer-api
```

Compare the returned addresses with Pod IPs:

```bash
kubectl get pods -n service-lab-headless -l app=peer-api -o wide
```

## Progressive hints

1. Headless Services still use the `ClusterIP` type.
2. The special value is the word `None`, not a blank value.
3. DNS should return multiple addresses when multiple Pods are ready.

## Expected result

`kubectl get svc` shows:

```text
CLUSTER-IP: None
```

DNS returns three Pod IP addresses instead of one Service virtual IP.

## Common errors

### DNS returns one ClusterIP

The Service is not headless. Inspect `spec.clusterIP`.

### DNS returns no addresses

Check selector matching and Pod readiness:

```bash
kubectl get pods -n service-lab-headless --show-labels
kubectl get endpointslices -n service-lab-headless
```

### Results appear in a different order

DNS answer ordering is not a stable contract. Compare sets of addresses, not
their order.

## Clean up

```bash
./cleanup.sh
```
