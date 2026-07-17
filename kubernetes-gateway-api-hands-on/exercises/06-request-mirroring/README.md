# Exercise 6 — Request Mirroring

## 1. Concept

Request mirroring sends the original request to the primary backend and a copy to a second backend. The client receives only the primary backend's response; the mirrored backend's response is discarded.

## 2. Task

For `mirror.gateway.local`:

- Use `stable` as the primary backend.
- Mirror every request to the `mirror` Service.
- Confirm the client response comes from `stable`.
- Confirm the mirrored request appears in the `mirror` Pod logs.

## 3. Incomplete file

```bash
cat exercise/route.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/route.yaml
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8080:80
curl -s -H 'Host: mirror.gateway.local' http://127.0.0.1:8080/test
kubectl logs deployment/mirror -n gateway-lab --tail=10
```

## 5. Progressive hints

**Hint 1:** The filter type is `RequestMirror`.

**Hint 2:** The primary backend remains under the rule's `backendRefs`.

**Hint 3:** The mirrored backend goes under `requestMirror.backendRef` using a singular reference.

## 6. Expected result

The client response should report `"app":"stable"`. A matching request should be visible in the mirror Deployment logs.

## 7. Common errors and troubleshooting

### Client receives the mirror response

The mirrored Service should not be listed as a second normal backend. It belongs in the `RequestMirror` filter.

### No mirror log appears

```bash
kubectl get pods -n gateway-lab -l app=mirror
kubectl logs deployment/mirror -n gateway-lab --since=5m
kubectl describe httproute mirror-route -n gateway-lab
```

### Side-effect warning

Do not mirror unsafe production requests into a backend that performs real writes, payments, notifications, or other external side effects.

## 8. Completed solution

```bash
kubectl apply -f solution/route.yaml
./validate.sh
```
