# Exercise 01 — Create a Basic Ingress

## 1. Concept

An Ingress rule maps an external HTTP host and path to a Kubernetes Service. The Ingress object stores the rule; the ingress controller turns it into proxy configuration.

## 2. Task

Complete `exercise/ingress.yaml` so that:

- The hostname is `basic.ingress.local`.
- Requests are routed to the `frontend` Service.
- The Ingress refers to Service port `80`.

## 3. Incomplete File

```text
exercise/ingress.yaml
```

Copy it before editing:

```bash
cp exercises/01-basic-ingress/exercise/ingress.yaml /tmp/01-basic-ingress.yaml
```

Replace all `________` values.

## 4. Run and Test

```bash
kubectl apply -f /tmp/01-basic-ingress.yaml
kubectl get ingress basic-ingress -n ingress-lab

export INGRESS_IP="$(minikube ip)"
curl --resolve basic.ingress.local:80:"$INGRESS_IP" \
  http://basic.ingress.local/
```

## 5. Progressive Hints

1. The `host` value belongs under `spec.rules`.
2. The backend name must match an existing Service, not a Deployment.
3. The Ingress references the Service's `port`, not the container's internal implementation details.

## 6. Expected Result

The response contains:

```text
Frontend Service
```

It also displays the name of the Pod that handled the request.

## 7. Common Errors

### Empty `ADDRESS`

```bash
kubectl describe ingress basic-ingress -n ingress-lab
kubectl get pods -n ingress-nginx
```

The controller may still be starting.

### `404 Not Found`

Confirm that curl sends the correct host:

```bash
curl -v --resolve basic.ingress.local:80:"$INGRESS_IP" \
  http://basic.ingress.local/
```

### Service has no endpoints

```bash
kubectl get endpointslices \
  -n ingress-lab \
  -l kubernetes.io/service-name=frontend
```

## 8. Completed Solution

```bash
kubectl delete ingress basic-ingress -n ingress-lab --ignore-not-found
kubectl apply -f exercises/01-basic-ingress/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/01-basic-ingress/solution/ingress.yaml
```
