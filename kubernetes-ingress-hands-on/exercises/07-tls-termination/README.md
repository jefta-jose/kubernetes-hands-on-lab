# Exercise 07 — TLS Termination

## 1. Concept

With TLS termination, the ingress proxy accepts HTTPS, presents the certificate, decrypts the request, and then routes it to the backend Service.

## 2. Task

Configure the Ingress to use:

- Host: `tls.ingress.local`
- TLS Secret: `tls-ingress-local`

The hostname under `tls.hosts` must match the rule hostname and certificate.

## 3. Incomplete File

```bash
cp exercises/07-tls-termination/exercise/ingress.yaml \
  /tmp/07-tls-ingress.yaml
```

Generate the local certificate and Secret:

```bash
./scripts/generate-tls-secret.sh \
  tls.ingress.local \
  tls-ingress-local
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/07-tls-ingress.yaml
```

In a separate terminal, leave the tunnel running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

This finds the `ingress-nginx-controller` Service in the `ingress-nginx`
namespace. The mappings use `host-port:Service-port`: `8080:80` forwards HTTP,
and `8443:443` forwards HTTPS. Keep the command running during the test.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTPS_PORT=8443

curl -vk --resolve tls.ingress.local:"$INGRESS_HTTPS_PORT":"$INGRESS_HOST" \
  https://tls.ingress.local:"$INGRESS_HTTPS_PORT"/
```

The exports describe the local HTTPS listener, `127.0.0.1:8443`. `--resolve`
uses `hostname:port:address`, so curl connects to that listener but retains
`tls.ingress.local` for both the TLS SNI name and the HTTP hostname. That allows
NGINX to choose the matching certificate and Ingress rule. `-k` accepts the
self-signed lab certificate; `-v` displays the TLS and request details.

Inspect the Secret:

```bash
kubectl get secret tls-ingress-local -n ingress-lab
```

## 5. Progressive Hints

1. `tls` belongs under `spec`.
2. The same hostname appears in both `tls.hosts` and `rules.host`.
3. `secretName` references a Secret in the same namespace as the Ingress.

## 6. Expected Result

The TLS handshake succeeds and the response comes from the frontend Service.

Curl uses `-k` because the local certificate is self-signed.

## 7. Common Errors

### Default fake certificate is served

The Secret name may be wrong, the Secret may be missing, or the hostname may not match.

```bash
kubectl describe ingress tls-ingress -n ingress-lab
kubectl get secret tls-ingress-local -n ingress-lab
```

### Certificate hostname mismatch

Regenerate the Secret with the exact hostname.

### HTTPS is unreachable

Confirm that the controller exposes port `443` and that the port-forward is
still running and reports forwarding on `127.0.0.1:8443`:

```bash
kubectl get service -n ingress-nginx
```

## 8. Completed Solution

```bash
kubectl delete ingress tls-ingress -n ingress-lab --ignore-not-found
kubectl apply -f exercises/07-tls-termination/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/07-tls-termination/solution/ingress.yaml
kubectl delete secret tls-ingress-local -n ingress-lab --ignore-not-found
```
