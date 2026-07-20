# Exercise 03 — Path-Based Routing

## 1. Concept

Path-based routing allows one hostname to expose several backend Services. The ingress proxy selects a backend using the URL path.

## 2. Task

Complete the manifest so that:

- `/quotes` routes to `quote-api`.
- `/questions` routes to `quiz-api`.
- Both paths use `Prefix`.

## 3. Incomplete File

```bash
cp exercises/03-path-based-routing/exercise/ingress.yaml /tmp/03-path-routing.yaml
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/03-path-routing.yaml
```

In a separate terminal, leave the tunnel running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

The command selects the `ingress-nginx-controller` Service from the
`ingress-nginx` namespace. `8080:80` maps host HTTP port `8080` to Service port
`80`; `8443:443` maps host HTTPS port `8443` to Service port `443`. Keep the
command running because it is the live connection into the cluster.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080

curl --resolve routes.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://routes.ingress.local:"$INGRESS_HTTP_PORT"/quotes

curl --resolve routes.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://routes.ingress.local:"$INGRESS_HTTP_PORT"/questions
```

The variables identify the local end of that connection: `127.0.0.1:8080`.
`--resolve` uses `hostname:port:address`, so curl connects there while still
sending `routes.ingress.local` as the HTTP hostname. NGINX first matches that
host and then uses `/quotes` or `/questions` from the URL to select a path rule.

Also test a child path:

```bash
curl --resolve routes.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://routes.ingress.local:"$INGRESS_HTTP_PORT"/questions/7
```

## 5. Progressive Hints

1. Every URL path starts with `/`.
2. `Prefix` matches complete path elements below the configured path.
3. Ingress normally preserves the requested path when forwarding it.

## 6. Expected Result

- `/quotes` returns a page containing `Quote API`.
- `/questions` and `/questions/7` return a page containing `Quiz API`.

Ingress preserves each requested path when it forwards the request. The demo
applications are configured to respond on every path so the returned page
clearly identifies the selected backend.

## 7. Common Errors

### A request unexpectedly returns 404

First confirm that the current shared applications have been deployed:

```bash
make apps
kubectl rollout status deployment/quote-api -n ingress-lab
kubectl rollout status deployment/quiz-api -n ingress-lab
```

Then use response headers and controller logs to distinguish an unmatched
Ingress rule from a backend response:

```bash
curl -i --resolve routes.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://routes.ingress.local:"$INGRESS_HTTP_PORT"/questions

kubectl logs -n ingress-nginx \
  deployment/ingress-nginx-controller \
  --tail=50
```

If curl reports `Connection refused`, restart the port-forward shown in section 4.

### Rule not listed

```bash
kubectl describe ingress path-routing -n ingress-lab
```

## 8. Completed Solution

```bash
kubectl delete ingress path-routing -n ingress-lab --ignore-not-found
kubectl apply -f exercises/03-path-based-routing/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/03-path-based-routing/solution/ingress.yaml
```
