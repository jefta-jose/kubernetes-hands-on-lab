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
export INGRESS_IP="$(minikube ip)"

curl -vk --resolve tls.ingress.local:443:"$INGRESS_IP" \
  https://tls.ingress.local/
```

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

Check that the ingress controller exposes port `443`:

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
