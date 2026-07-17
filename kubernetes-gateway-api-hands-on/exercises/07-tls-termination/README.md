# Exercise 7 — TLS Termination

## 1. Concept

With TLS termination, the client establishes HTTPS with the Gateway. The Gateway decrypts the request, so an `HTTPRoute` can still match HTTP hostnames, paths, and headers. The listener references a Kubernetes TLS Secret containing the certificate and private key.

## 2. Task

- Create a TLS Secret for `secure.gateway.local`.
- Add an HTTPS listener on port `443` to `lab-gateway`.
- Configure `tls.mode: Terminate`.
- Attach an HTTPRoute specifically to the HTTPS listener.
- Forward traffic to `stable`.

## 3. Incomplete files

```bash
cat exercise/gateway.yaml
cat exercise/route.yaml
```

Create the certificate Secret first:

```bash
../../scripts/create-tls-secret.sh gateway-lab gateway-lab-tls secure.gateway.local
```

## 4. Run and test

```bash
kubectl apply -f exercise/
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8443:443
curl -sk --resolve secure.gateway.local:8443:127.0.0.1 \
  https://secure.gateway.local:8443/
```

`-k` is used because this is a self-signed learning certificate.

## 5. Progressive hints

**Hint 1:** An HTTPS listener uses `protocol: HTTPS` and `tls.mode: Terminate`.

**Hint 2:** `certificateRefs` points to `gateway-lab-tls` in the Gateway's namespace.

**Hint 3:** Attach the Route to the HTTPS listener by setting `sectionName: https`.

## 6. Expected result

The HTTPS request should return JSON from the `stable` application.

## 7. Common errors and troubleshooting

### `curl: connection refused`

Confirm the Gateway listener is programmed and the Envoy Service exposes port 443:

```bash
kubectl describe gateway lab-gateway -n gateway-lab
kubectl get svc -n envoy-gateway-system
```

### `InvalidCertificateRef`

```bash
kubectl get secret gateway-lab-tls -n gateway-lab
kubectl describe gateway lab-gateway -n gateway-lab
```

The Secret must exist in the Gateway namespace and have type `kubernetes.io/tls`.

### Certificate hostname mismatch

Use exactly `secure.gateway.local` in both the generated certificate and the curl `--resolve` hostname.

## 8. Completed solution

```bash
../../scripts/create-tls-secret.sh gateway-lab gateway-lab-tls secure.gateway.local
kubectl apply -f solution/
./validate.sh
```
