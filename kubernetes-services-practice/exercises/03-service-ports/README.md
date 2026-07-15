# Exercise 03 — Service Port and Target Port

## Concept

`port` is the port exposed by the Service. `targetPort` is the destination
port on the selected Pods.

They do not need to match. A Service can present a conventional interface,
such as port 80, while the application listens on a different container port.

Named target ports reduce coupling between the Service and a specific number.

## Task

Complete the manifest so that:

- The container port is named `web`
- The Service exposes port `80`
- The Service uses `targetPort: web`
- The selector matches `app: ports-demo`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/ports-demo -n service-lab-ports
kubectl exec -n service-lab-ports service-client -- curl -s http://ports-demo
```

Inspect the translation:

```bash
kubectl describe svc ports-demo -n service-lab-ports
kubectl get endpointslices -n service-lab-ports -o wide
```

## Progressive hints

1. `targetPort` may be a number or the name of a container port.
2. The application listens on `8080`.
3. Clients should not need to include `:8080` in the URL.

## Expected result

```text
service-port-80-to-container-port-8080
```

## Common errors

### Service accepts connections but backend fails

The named `targetPort` must exactly match the container port name.

```bash
kubectl get deployment ports-demo -n service-lab-ports -o yaml
kubectl get svc ports-demo -n service-lab-ports -o yaml
```

### Endpoints exist on the wrong port

Inspect the EndpointSlice:

```bash
kubectl describe endpointslice -n service-lab-ports
```

## Clean up

```bash
./cleanup.sh
```
