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
```

In a separate terminal, leave the tunnel running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

This creates a live connection to the `ingress-nginx-controller` Service in the
`ingress-nginx` namespace. Mappings are `host-port:Service-port`, so HTTP uses
`8080:80` and HTTPS uses `8443:443`. Leave this terminal running.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080

curl --resolve paths.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://paths.ingress.local:"$INGRESS_HTTP_PORT"/

curl --resolve paths.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://paths.ingress.local:"$INGRESS_HTTP_PORT"/api

curl --resolve paths.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://paths.ingress.local:"$INGRESS_HTTP_PORT"/api/quote

curl --resolve paths.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://paths.ingress.local:"$INGRESS_HTTP_PORT"/api/quote/1
```

The exports name the local endpoint, `127.0.0.1:8080`. Curl reads `--resolve`
as `hostname:port:address`: it connects to that local endpoint but preserves
`paths.ingress.local` as the HTTP hostname. The different URL paths then let
NGINX demonstrate exact, prefix, and precedence behavior.

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
