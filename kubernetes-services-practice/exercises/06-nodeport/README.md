# Exercise 06 — Exposing a Service with NodePort

## Concept

A NodePort Service allocates the same port on every cluster node. Traffic sent
to any node on that port is forwarded to a ready backend Pod selected by the
Service.

NodePort extends ClusterIP: the Service remains reachable internally through
its ClusterIP and externally through the node port.

## Task

Complete the Service so that:

- Its type is `NodePort`
- It exposes Service port `80`
- It forwards to the named target port `http`
- It uses node port `30080`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/public-api -n service-lab-nodeport
```

Inspect the Service:

```bash
kubectl get svc public-api -n service-lab-nodeport
kubectl describe svc public-api -n service-lab-nodeport
```

When using the included kind cluster:

```bash
curl http://localhost:8080
```

From inside the cluster:

```bash
kubectl run curl-test --rm -i --restart=Never \
  --image=curlimages/curl:8.10.1 \
  -n service-lab-nodeport \
  -- curl -s http://public-api
```

Minikube alternative:

```bash
minikube service public-api -n service-lab-nodeport --url
```

## Progressive hints

1. The valid Service type uses capital `N` and `P`.
2. The conventional HTTP Service port is `80`.
3. The backend container port is named `http`.
4. The kind cluster maps host port `8080` to node port `30080`.

## Expected result

```text
public-api
```

## Common errors

### localhost:8080 refuses the connection

Confirm you created the cluster with the included kind configuration:

```bash
kind get clusters
docker ps
```

The host mapping is configured when the cluster is created. Recreating the
cluster may be required.

### NodePort is rejected

The default NodePort range is normally `30000-32767`; use `30080`.

### Service has no endpoints

Compare labels and selectors:

```bash
kubectl get pods -n service-lab-nodeport --show-labels
kubectl describe svc public-api -n service-lab-nodeport
```

## Clean up

```bash
./cleanup.sh
```
