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
```

In a separate terminal, leave the tunnel running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

This forwards to the `ingress-nginx-controller` Service in the `ingress-nginx`
namespace. Port mappings are `host-port:Service-port`: `8080:80` is HTTP and
`8443:443` is HTTPS. The forwarding stops when this command stops.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080

curl --resolve known.default.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://known.default.ingress.local:"$INGRESS_HTTP_PORT"/

curl -i --resolve unknown.default.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://unknown.default.ingress.local:"$INGRESS_HTTP_PORT"/
```

The exported endpoint is the local listener, `127.0.0.1:8080`. Curl's
`--resolve` syntax is `hostname:port:address`, so both requests travel through
that listener while retaining different HTTP hostnames. The known hostname
matches a rule; the unknown one demonstrates the default backend.

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
