# Exercise 04 — Service Discovery with DNS

## Concept

Cluster DNS creates records for Services. A Pod in the same namespace can
usually use the short Service name. A Pod in another namespace should use at
least:

```text
SERVICE.NAMESPACE
```

The fully qualified form is:

```text
SERVICE.NAMESPACE.svc.cluster.local
```

## Task

Complete the manifest so that:

- The Service is named `catalog`
- It lives in `service-lab-dns`
- The client command uses the full Service DNS name
- The client namespace remains `service-lab-dns-client`

## Run

```bash
cp exercise.yaml my-answer.yaml
kubectl apply -f my-answer.yaml
kubectl rollout status deployment/catalog -n service-lab-dns
kubectl wait --for=condition=Ready pod/dns-client \
  -n service-lab-dns-client --timeout=120s
```

Resolve the Service:

```bash
kubectl exec -n service-lab-dns-client dns-client -- \
  nslookup catalog.service-lab-dns.svc.cluster.local
```

Send a request:

```bash
kubectl exec -n service-lab-dns-client dns-client -- \
  wget -qO- http://catalog.service-lab-dns.svc.cluster.local
```

## Progressive hints

1. The Service name becomes the first DNS label.
2. Cross-namespace discovery must include the Service namespace.
3. The cluster DNS suffix is normally `svc.cluster.local`.
4. BusyBox includes `nslookup` and `wget`.

## Expected result

DNS resolves to the Service ClusterIP, and the request returns:

```text
catalog-v1
```

## Common errors

### Short name fails from the client namespace

That is expected. `catalog` alone searches the client's namespace first.

### DNS resolves but HTTP fails

Check the Service selector and target port:

```bash
kubectl describe svc catalog -n service-lab-dns
kubectl get endpointslices -n service-lab-dns
```

### DNS does not resolve

Inspect the client's resolver configuration:

```bash
kubectl exec -n service-lab-dns-client dns-client -- cat /etc/resolv.conf
kubectl get pods -n kube-system
kubectl get svc -n kube-system
```

## Clean up

```bash
./cleanup.sh
```
