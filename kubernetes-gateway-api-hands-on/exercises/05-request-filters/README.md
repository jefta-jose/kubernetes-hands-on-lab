# Exercise 5 — URL Rewrite and Header Modification

## 1. Concept

HTTPRoute filters can transform a request before it reaches the backend. `URLRewrite` can replace a matched path prefix, while `RequestHeaderModifier` can add, set, or remove request headers.

## 2. Task

For requests to:

```text
http://filters.gateway.local/legacy/users
```

make the backend receive:

```text
path: /api/users
header: X-Gateway-Lab: rewritten
```

Send the transformed request to `stable`.

## 3. Incomplete file

```bash
cat exercise/route.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/route.yaml
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8080:80
curl -s -H 'Host: filters.gateway.local' http://127.0.0.1:8080/legacy/users
```

## 5. Progressive hints

**Hint 1:** Match `/legacy` with `PathPrefix`.

**Hint 2:** Use `ReplacePrefixMatch`, not `ReplaceFullPath`, so `/users` is preserved.

**Hint 3:** Use `set` when the Gateway should replace an existing header value.

## 6. Expected result

The JSON response should contain:

```json
"path":"/api/users"
```

and:

```json
"x-gateway-lab":"rewritten"
```

## 7. Common errors and troubleshooting

### Backend still sees `/legacy/users`

Check the filter nesting and spelling of `ReplacePrefixMatch`.

### Header is missing

The echo server lowercases header names in the response. Search for `x-gateway-lab`, not `X-Gateway-Lab`.

### Route is rejected

Inspect the Route status and verify Envoy Gateway supports the selected filters:

```bash
kubectl describe httproute filter-route -n gateway-lab
```

## 8. Completed solution

```bash
kubectl apply -f solution/route.yaml
./validate.sh
```
