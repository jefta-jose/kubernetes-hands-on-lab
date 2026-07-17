# Exercise 2 — Basic HTTPRoute

## 1. Concept

A `Gateway` accepts connections, while an `HTTPRoute` decides which HTTP requests match and which backend Service receives them. `parentRefs` attaches the Route to a Gateway, and `backendRefs` points to the Service.

## 2. Task

Create a Route that:

- Attaches to `gateway-lab/lab-gateway`.
- Matches the hostname `basic.gateway.local`.
- Sends all matching traffic to the `stable` Service on port `8080`.

Exercise 1 must already be complete.

## 3. Incomplete file

```bash
cat exercise/route.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/route.yaml
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8080:80
curl -s -H 'Host: basic.gateway.local' http://127.0.0.1:8080/
../../scripts/stop-forward.sh 8080
```

Automated validation:

```bash
./validate.sh
```

## 5. Progressive hints

**Hint 1:** The parent kind defaults to `Gateway`, but writing it explicitly makes the relationship easier to read.

**Hint 2:** `backendRefs.port` is the Service port, not the container port name.

**Hint 3:** The local URL is `127.0.0.1`, but hostname matching uses the `Host` header.

## 6. Expected result

The response should contain:

```json
{"app":"stable","version":"v1"}
```

The complete response also includes the method, path, headers, and body.

## 7. Common errors and troubleshooting

### Response is 404

```bash
kubectl describe httproute basic-route -n gateway-lab
kubectl get gateway lab-gateway -n gateway-lab -o yaml
```

Verify that the Route hostname matches both the listener wildcard and the request `Host` header.

### `BackendNotFound`

```bash
kubectl get svc stable -n gateway-lab
kubectl get endpoints stable -n gateway-lab
```

### Port-forward cannot find a Service

Wait until the Gateway is programmed:

```bash
kubectl wait --for=condition=Programmed gateway/lab-gateway -n gateway-lab --timeout=5m
```

## 8. Completed solution

```bash
kubectl apply -f solution/route.yaml
```
