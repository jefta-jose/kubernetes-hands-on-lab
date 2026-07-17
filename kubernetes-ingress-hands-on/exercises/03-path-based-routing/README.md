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
export INGRESS_IP="$(minikube ip)"

curl --resolve routes.ingress.local:80:"$INGRESS_IP" \
  http://routes.ingress.local/quotes

curl --resolve routes.ingress.local:80:"$INGRESS_IP" \
  http://routes.ingress.local/questions
```

Also test a child path:

```bash
curl --resolve routes.ingress.local:80:"$INGRESS_IP" \
  http://routes.ingress.local/questions/7
```

## 5. Progressive Hints

1. Every URL path starts with `/`.
2. `Prefix` matches complete path elements below the configured path.
3. Ingress normally preserves the requested path when forwarding it.

## 6. Expected Result

- `/quotes` reaches the quote API.
- `/questions` and `/questions/7` reach the quiz API.

## 7. Common Errors

### Backend returns NGINX 404

The ingress reached the backend, but NGINX may not have a file for the preserved path. In this lab, the controller is expected to route correctly, while the backend may still return its own 404 for non-root files.

Use response headers and controller logs to distinguish routing from application behaviour:

```bash
curl -i --resolve routes.ingress.local:80:"$INGRESS_IP" \
  http://routes.ingress.local/questions
```

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
