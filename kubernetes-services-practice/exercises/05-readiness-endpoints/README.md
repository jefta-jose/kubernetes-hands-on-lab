# Exercise 05 — Readiness and EndpointSlices

## Concept

A Service should route traffic only to endpoints that are ready to receive it.
A readiness probe controls whether a Pod is considered ready.

Kubernetes records backend addresses and readiness conditions in
EndpointSlice objects. A running but unready Pod should not receive normal
Service traffic.

## Task

The manifest creates two Pods:

- `ready-backend` should pass its readiness probe
- `unready-backend` should fail its readiness probe
- Both Pods share the selector label `app: readiness-demo`

Fill in:

- The correct readiness probe port for the ready Pod
- The deliberately incorrect readiness probe port for the unready Pod
- The Service selector value
- The Service `targetPort`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl wait --for=condition=Ready pod/ready-backend \
  -n service-lab-readiness --timeout=120s
```

The second Pod should remain unready:

```bash
kubectl get pods -n service-lab-readiness
```

Inspect Service endpoints:

```bash
kubectl get endpointslices -n service-lab-readiness -o yaml
```

Test repeated requests:

```bash
for i in 1 2 3 4; do
  kubectl exec -n service-lab-readiness service-client -- \
    curl -s http://readiness-demo
done
```

## Progressive hints

1. Both application containers listen on port `5678`.
2. A successful TCP readiness probe should check the listening port.
3. Use a different, closed port to keep the second Pod unready.
4. The Service's named target port must match the container port name.

## Expected result

Only this response appears:

```text
ready-backend
```

The unready Pod exists but is excluded from ready Service endpoints.

## Common errors

### Both Pods are ready

The unready Pod's probe is checking a working port. Inspect it:

```bash
kubectl describe pod unready-backend -n service-lab-readiness
```

### No endpoints are ready

Check the ready Pod's probe and Service selector.

### EndpointSlice output is confusing

Use a compact command:

```bash
kubectl get endpointslice -n service-lab-readiness \
  -l kubernetes.io/service-name=readiness-demo \
  -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{" ready="}{.conditions.ready}{"\n"}{end}'
```

## Clean up

```bash
./cleanup.sh
```
