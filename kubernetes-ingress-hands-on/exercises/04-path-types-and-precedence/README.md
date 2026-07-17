# Exercise 04 — Path Types and Precedence

## 1. Concept

`Exact` requires the request path to match exactly. `Prefix` matches complete path elements. More specific matches take precedence over broader ones.

## 2. Task

Choose path types so that:

- `/` is the general frontend fallback.
- `/api` and its child paths route to `quiz-api`.
- Only the exact path `/api/quote` routes to `quote-api`.

## 3. Incomplete File

```bash
cp exercises/04-path-types-and-precedence/exercise/ingress.yaml \
  /tmp/04-path-types.yaml
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/04-path-types.yaml
export INGRESS_IP="$(minikube ip)"

curl --resolve paths.ingress.local:80:"$INGRESS_IP" \
  http://paths.ingress.local/

curl --resolve paths.ingress.local:80:"$INGRESS_IP" \
  http://paths.ingress.local/api

curl --resolve paths.ingress.local:80:"$INGRESS_IP" \
  http://paths.ingress.local/api/quote

curl --resolve paths.ingress.local:80:"$INGRESS_IP" \
  http://paths.ingress.local/api/quote/1
```

## 5. Progressive Hints

1. `/` should use `Prefix` so it can match general requests.
2. `/api` should also use `Prefix`.
3. `/api/quote` must use the type that rejects `/api/quote/1`.

## 6. Expected Result

- `/` selects `frontend`.
- `/api` selects `quiz-api`.
- `/api/quote` selects `quote-api`.
- `/api/quote/1` does not match the exact quote rule; it falls back to the `/api` prefix rule.

## 7. Common Errors

### `/api/quote/1` reaches quote-api

Check that `/api/quote` uses `Exact`, not `Prefix`.

### `/foobar` matches `/foo`

Kubernetes `Prefix` matching is element-based. `/foo` should not match `/foobar`.

### Difficult to identify the selected backend

Inspect controller access logs:

```bash
kubectl logs -n ingress-nginx \
  deployment/ingress-nginx-controller \
  --tail=100
```

## 8. Completed Solution

```bash
kubectl delete ingress path-types -n ingress-lab --ignore-not-found
kubectl apply -f exercises/04-path-types-and-precedence/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/04-path-types-and-precedence/solution/ingress.yaml
```
