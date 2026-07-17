# Exercise 10 — Final Challenge

## 1. Concept

This challenge combines the major Ingress concepts:

- IngressClass selection
- Multiple host rules
- Path-based routing
- `Exact` and `Prefix` path types
- TLS termination
- Controller-specific annotations
- A default backend

## 2. Task

Complete the Ingress so that:

- HTTP redirects to HTTPS.
- The proxy read timeout is `30` seconds.
- The selected class is `nginx`.
- The default backend is `custom-404`.
- TLS uses the Secret `final-ingress-tls`.
- `portal.final.ingress.local/` routes to `frontend` using `Prefix`.
- Exact `/quote` on `api.final.ingress.local` routes to `quote-api`.
- `/questions` and its child paths route to `quiz-api` using `Prefix`.

## 3. Incomplete File

```bash
cp exercises/10-final-challenge/exercise/ingress.yaml \
  /tmp/10-final-challenge.yaml
```

A single self-signed certificate must cover both hostnames. Generate it manually:

```bash
TMP_DIR="$(mktemp -d)"

openssl req \
  -x509 \
  -newkey rsa:2048 \
  -nodes \
  -sha256 \
  -days 365 \
  -keyout "$TMP_DIR/tls.key" \
  -out "$TMP_DIR/tls.crt" \
  -subj "/CN=portal.final.ingress.local" \
  -addext "subjectAltName=DNS:portal.final.ingress.local,DNS:api.final.ingress.local"

kubectl create secret tls final-ingress-tls \
  -n ingress-lab \
  --cert="$TMP_DIR/tls.crt" \
  --key="$TMP_DIR/tls.key" \
  --dry-run=client \
  -o yaml |
kubectl apply -f -

rm -rf "$TMP_DIR"
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/10-final-challenge.yaml
export INGRESS_IP="$(minikube ip)"
```

Confirm HTTP redirect:

```bash
curl -I \
  --resolve portal.final.ingress.local:80:"$INGRESS_IP" \
  http://portal.final.ingress.local/
```

Test the frontend over HTTPS:

```bash
curl -sk \
  --resolve portal.final.ingress.local:443:"$INGRESS_IP" \
  https://portal.final.ingress.local/
```

Test the exact quote route:

```bash
curl -sk \
  --resolve api.final.ingress.local:443:"$INGRESS_IP" \
  https://api.final.ingress.local/quote
```

Test the quiz prefix route:

```bash
curl -sk \
  --resolve api.final.ingress.local:443:"$INGRESS_IP" \
  https://api.final.ingress.local/questions/42
```

Test the fallback using an unmatched host:

```bash
curl -ski \
  --resolve unknown.final.ingress.local:443:"$INGRESS_IP" \
  https://unknown.final.ingress.local/
```

Because the certificate does not include the unknown hostname, `-k` is required for this local fallback test.

## 5. Progressive Hints

1. Annotation values are strings, even when they represent booleans or numbers.
2. The default backend must reference a Service and one of its exposed ports.
3. The TLS Secret must be in the same namespace as the Ingress.
4. `/quote` must not match `/quote/1`.
5. `/questions` must match `/questions/42`.

## 6. Expected Result

- HTTP receives a redirect to HTTPS.
- The portal host reaches the frontend.
- Exact `/quote` selects the quote API.
- `/questions/42` selects the quiz API.
- An unmatched request reaches the custom 404 backend.

## 7. Common Errors

### HTTPS uses the wrong certificate

```bash
kubectl get secret final-ingress-tls -n ingress-lab
kubectl describe ingress final-challenge -n ingress-lab
```

### `/quote/1` reaches quote-api

The quote path must use `Exact`.

### Unknown host does not reach this default backend

Another active Ingress may own a default backend or overlapping host rule. Delete earlier exercise Ingresses:

```bash
kubectl delete ingress --all -n ingress-lab
kubectl apply -f /tmp/10-final-challenge.yaml
```

### Annotation rejected

Inspect controller events and logs:

```bash
kubectl get events -n ingress-lab --sort-by=.lastTimestamp
kubectl logs -n ingress-nginx \
  deployment/ingress-nginx-controller \
  --tail=200
```

## 8. Completed Solution

```bash
kubectl delete ingress --all -n ingress-lab
kubectl apply -f exercises/10-final-challenge/solution/ingress.yaml
```

Run all tests above.

Clean up:

```bash
kubectl delete -f exercises/10-final-challenge/solution/ingress.yaml
kubectl delete secret final-ingress-tls -n ingress-lab --ignore-not-found
```
