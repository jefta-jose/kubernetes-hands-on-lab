# Exercise 3 — Path and Header Routing

## 1. Concept

An `HTTPRoute` may contain multiple rules. A rule can match request properties such as paths and headers, then send the request to a different backend. A rule without matches acts as a catch-all.

## 2. Task

Complete a Route for `routing.gateway.local` with this behavior:

```text
/ with X-Release: canary -> canary
/auth/...                 -> auth
/orders/...               -> orders
anything else             -> stable
```

## 3. Incomplete file

```bash
cat exercise/route.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/route.yaml
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8080:80

curl -s -H 'Host: routing.gateway.local' http://127.0.0.1:8080/
curl -s -H 'Host: routing.gateway.local' http://127.0.0.1:8080/auth/login
curl -s -H 'Host: routing.gateway.local' http://127.0.0.1:8080/orders/42
curl -s -H 'Host: routing.gateway.local' -H 'X-Release: canary' http://127.0.0.1:8080/
```

## 5. Progressive hints

**Hint 1:** Use `PathPrefix` for `/auth` and `/orders`.

**Hint 2:** Header matching uses `type: Exact`.

**Hint 3:** Put the catch-all rule last so the manifest reads from most specific to least specific.

## 6. Expected result

Each request should report the expected application name in its JSON response.

## 7. Common errors and troubleshooting

### Every request reaches the same backend

Inspect the live object and confirm the `matches` blocks are nested under the correct rule:

```bash
kubectl get httproute routing-route -n gateway-lab -o yaml
```

### Header route does not match

Use the exact header value:

```bash
curl -H 'X-Release: canary' ...
```

### Route rejected

```bash
kubectl describe httproute routing-route -n gateway-lab
```

Check `Accepted` and `ResolvedRefs` separately.

## 8. Completed solution

```bash
kubectl apply -f solution/route.yaml
./validate.sh
```
