# Exercise 08 — DNS Aliases with ExternalName

## Concept

An ExternalName Service creates a DNS CNAME-style alias. It does not select
Pods and does not need EndpointSlices.

Although commonly used to name an external dependency, it can also alias an
existing internal Service. This exercise remains fully local by aliasing an
internal backend.

## Task

Complete the alias Service so that:

- Its name is `inventory-api`
- Its type is `ExternalName`
- It points to `backend.service-lab-alias.svc.cluster.local`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/backend -n service-lab-alias
kubectl wait --for=condition=Ready pod/alias-client \
  -n service-lab-alias --timeout=120s
```

Resolve the alias:

```bash
kubectl exec -n service-lab-alias alias-client -- nslookup inventory-api
```

Call the aliased Service:

```bash
kubectl exec -n service-lab-alias alias-client -- \
  wget -qO- http://inventory-api
```

## Progressive hints

1. ExternalName Services have no selector.
2. The `externalName` value must be a DNS name, not an IP address.
3. The destination in this exercise is the backend Service's FQDN.

## Expected result

```text
inventory-backend
```

The alias Service should not have a normal ClusterIP or its own backend
EndpointSlice.

## Common errors

### The API rejects the Service

Check the exact capitalization of `ExternalName`.

### DNS works but HTTP fails

Confirm the target Service works directly:

```bash
kubectl exec -n service-lab-alias alias-client -- \
  wget -qO- http://backend
```

### HTTPS or Host header problems

ExternalName aliases operate at DNS level. Some HTTP/TLS applications validate
the requested hostname. This simple HTTP backend does not.

## Clean up

```bash
./cleanup.sh
```
