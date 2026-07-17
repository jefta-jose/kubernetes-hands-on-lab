# Exercise 06 — Configure a Default Backend

## 1. Concept

`spec.defaultBackend` is the catch-all backend used when no host or path rule matches.

## 2. Task

Configure the default backend to use:

- Service: `custom-404`
- Service port name: `http`

Keep the known host routed to the frontend.

## 3. Incomplete File

```bash
cp exercises/06-default-backend/exercise/ingress.yaml \
  /tmp/06-default-backend.yaml
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/06-default-backend.yaml
export INGRESS_IP="$(minikube ip)"

curl --resolve known.default.ingress.local:80:"$INGRESS_IP" \
  http://known.default.ingress.local/

curl -i --resolve unknown.default.ingress.local:80:"$INGRESS_IP" \
  http://unknown.default.ingress.local/
```

## 5. Progressive Hints

1. `defaultBackend` is a sibling of `rules`.
2. It references a Service exactly like a rule backend does.
3. The custom fallback Service intentionally returns HTTP status `404`.

## 6. Expected Result

The known host reaches the frontend. The unknown host returns:

```text
Custom Ingress Lab 404: no rule matched this request.
```

with HTTP status `404`.

## 7. Common Errors

### Default backend is never used

Make sure the test hostname does not match an existing Ingress rule from another exercise.

List all active rules:

```bash
kubectl get ingress -n ingress-lab
```

Delete conflicting exercise Ingresses when necessary.

### Backend endpoint missing

```bash
kubectl get endpointslices \
  -n ingress-lab \
  -l kubernetes.io/service-name=custom-404
```

## 8. Completed Solution

```bash
kubectl delete ingress default-backend -n ingress-lab --ignore-not-found
kubectl apply -f exercises/06-default-backend/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/06-default-backend/solution/ingress.yaml
```
