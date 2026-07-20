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
```

In a separate terminal, start a host-reachable tunnel and leave it running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

This asks `kubectl` to find the Service named `ingress-nginx-controller` in the
`ingress-nginx` namespace. That Service is the entry point to the NGINX ingress
controller. A port mapping is written as `host-port:Service-port`, so `8080:80`
forwards local HTTP traffic to Service port `80`, while `8443:443` does the same
for HTTPS. The forward exists only while this command keeps running.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080

curl --resolve basic.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://basic.ingress.local:"$INGRESS_HTTP_PORT"/
```

`export` saves reusable values in the current shell. `127.0.0.1` means this
host, and `8080` is the local HTTP port opened by the port-forward. Curl's
`--resolve` value has the form `hostname:port:address`; it makes curl connect to
`127.0.0.1:8080` while retaining `basic.ingress.local` as the request hostname.
NGINX needs that hostname to match the Ingress rule. This mapping applies only
to this curl command and does not change your DNS or `/etc/hosts` file.

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
curl -v --resolve basic.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://basic.ingress.local:"$INGRESS_HTTP_PORT"/
```

If curl reports `Connection refused`, confirm that the port-forward terminal is
still running and reports forwarding on `127.0.0.1:8080`.

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
