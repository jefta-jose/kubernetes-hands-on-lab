# Exercise 02 — Host-Based Routing

## 1. Concept

Host-based routing allows several domain names to share one ingress address. The reverse proxy reads the HTTP `Host` header and selects the matching rule.

## 2. Task

Complete the manifest so that:

- `app.ingress.local` routes to `frontend`.
- `api.ingress.local` routes to `quote-api`.
- Both backends use the Service port named `http`.

## 3. Incomplete File

```bash
cp exercises/02-host-based-routing/exercise/ingress.yaml /tmp/02-host-routing.yaml
```

Replace every `________`.

## 4. Run and Test

```bash
kubectl apply -f /tmp/02-host-routing.yaml
export INGRESS_IP="$(minikube ip)"

curl --resolve app.ingress.local:80:"$INGRESS_IP" \
  http://app.ingress.local/

curl --resolve api.ingress.local:80:"$INGRESS_IP" \
  http://api.ingress.local/
```

## 5. Progressive Hints

1. Both hostnames can resolve to the same IP.
2. The request hostname, not the destination IP alone, selects the backend.
3. A backend port may be selected by name instead of number.

## 6. Expected Result

The first request reaches the frontend. The second reaches the quote API.

## 7. Common Errors

### Both requests reach the same backend

Check the two `host` values and verify the curl URLs differ.

### Direct IP request returns the wrong page

This request does not provide the intended host rule:

```bash
curl "http://$INGRESS_IP"
```

Use `--resolve` so the Host header is correct.

### Named port not found

```bash
kubectl get service frontend quote-api -n ingress-lab -o yaml
```

Verify both Services expose a port named `http`.

## 8. Completed Solution

```bash
kubectl delete ingress host-routing -n ingress-lab --ignore-not-found
kubectl apply -f exercises/02-host-based-routing/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/02-host-based-routing/solution/ingress.yaml
```
