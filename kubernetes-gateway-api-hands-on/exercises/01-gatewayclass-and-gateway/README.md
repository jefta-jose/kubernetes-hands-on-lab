# Exercise 1 — GatewayClass and Gateway

## 1. Concept

A `GatewayClass` identifies the controller that implements a family of Gateways. A `Gateway` selects that class and defines listeners that accept traffic on specific ports, protocols, and hostnames.

## 2. Task

Complete `exercise/gateway.yaml` so that:

- The `GatewayClass` is named `eg`.
- Envoy Gateway manages the class.
- A Gateway named `lab-gateway` exists in `gateway-lab`.
- It listens for HTTP traffic on port `80`.
- It accepts hostnames under `*.gateway.local`.
- Only Routes from the same namespace may attach.

## 3. Incomplete file

```bash
cat exercise/gateway.yaml
```

Replace each `________` with the correct value.

## 4. Run and test

```bash
kubectl apply -f exercise/gateway.yaml
kubectl get gatewayclass
kubectl get gateway -n gateway-lab
kubectl describe gateway lab-gateway -n gateway-lab
```

Validate the completed solution:

```bash
./validate.sh
```

## 5. Progressive hints

**Hint 1:** Envoy Gateway uses the controller name `gateway.envoyproxy.io/gatewayclass-controller`.

**Hint 2:** A Gateway selects its class through `spec.gatewayClassName`.

**Hint 3:** Listener hostname matching accepts wildcard hostnames such as `*.gateway.local`.

## 6. Expected result

The GatewayClass should become accepted, and the Gateway should eventually report `Programmed=True`. Envoy Gateway should also create a proxy Deployment and Service in `envoy-gateway-system`.

## 7. Common errors and troubleshooting

### GatewayClass is not accepted

```bash
kubectl describe gatewayclass eg
kubectl logs deployment/envoy-gateway -n envoy-gateway-system
```

Verify the controller name exactly matches the value expected by Envoy Gateway.

### Gateway remains unprogrammed

```bash
kubectl get gateway lab-gateway -n gateway-lab -o yaml
kubectl get pods,svc -n envoy-gateway-system
```

Check listener validity and confirm the Envoy Gateway controller is running.

### Address is empty

This is normal on a local cluster without a LoadBalancer implementation. Later exercises use `kubectl port-forward` to reach the Envoy Service.

## 8. Completed solution

```bash
cat solution/gateway.yaml
kubectl apply -f solution/gateway.yaml
```
