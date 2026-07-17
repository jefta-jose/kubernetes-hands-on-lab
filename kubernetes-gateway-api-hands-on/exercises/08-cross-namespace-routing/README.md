# Exercise 8 — Cross-Namespace Routing and ReferenceGrant

## 1. Concept

Cross-namespace Route-to-Gateway attachment is authorized by the Gateway listener's `allowedRoutes` policy. A Route that references a backend in another namespace requires a `ReferenceGrant` in the backend namespace.

This creates two separate trust decisions:

```text
May team-a attach to the infra Gateway?
May team-a reference the shared-services Service?
```

## 2. Task

Build this flow:

```text
team-a HTTPRoute
      |
      | parentRef
      v
infra/shared-gateway
      |
      | backendRef
      v
shared-services/shared-api
```

Requirements:

- The Gateway accepts Routes only from namespaces labelled `gateway-access: allowed`.
- The Route uses `team-a.shared.gateway.local`.
- A ReferenceGrant permits only `team-a` HTTPRoutes to reference the `shared-api` Service.

## 3. Incomplete files

```bash
cat exercise/gateway.yaml
cat exercise/route.yaml
cat exercise/referencegrant.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/
../../scripts/forward-gateway.sh infra shared-gateway 8080:80
curl -s -H 'Host: team-a.shared.gateway.local' http://127.0.0.1:8080/
```

## 5. Progressive hints

**Hint 1:** The namespace selector belongs under `listeners[].allowedRoutes.namespaces`.

**Hint 2:** The Route's `parentRefs` needs `namespace: infra`.

**Hint 3:** The ReferenceGrant is created in `shared-services`, because the target namespace owns the permission decision.

## 6. Expected result

The response should report:

```json
"app":"shared-api"
```

The Route status should show both `Accepted=True` and `ResolvedRefs=True`.

## 7. Common errors and troubleshooting

### `NotAllowedByListeners`

```bash
kubectl get namespace team-a --show-labels
kubectl describe gateway shared-gateway -n infra
```

### `RefNotPermitted`

```bash
kubectl get referencegrant -n shared-services -o yaml
kubectl describe httproute team-a-route -n team-a
```

Verify the `from` namespace, group, and kind, plus the `to` Service name.

### Route attaches but backend fails

```bash
kubectl get svc,endpoints shared-api -n shared-services
```

## 8. Completed solution

```bash
kubectl apply -f solution/
./validate.sh
```
