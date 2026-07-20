# Exercise 02 — Host-Based Routing

## 1. Concept

Host-based routing allows several domain names to share one ingress address. The reverse proxy reads the HTTP `Host` header and selects the matching rule.

## 2. Task

Complete the manifest so that:

- `app.ingress.local` routes to `frontend`.
- `api.ingress.local` routes to `quote-api`.
- Both backends use the Service port named `http`.

## 3. Incomplete File

```bash
cp exercises/02-host-based-routing/exercise/ingress.yaml /tmp/02-host-routing.yaml
```

Replace every `________`.

## 4. Run and Test

```bash
kubectl apply -f /tmp/02-host-routing.yaml
```

In a separate terminal, leave the tunnel running:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

`service/ingress-nginx-controller` means the Service named
`ingress-nginx-controller` in the `ingress-nginx` namespace. It is the entry
point to the controller. Port mappings use `host-port:Service-port`:
`8080:80` forwards local HTTP and `8443:443` forwards local HTTPS. The command
must remain running.

Back in the exercise terminal:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080

curl --resolve app.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://app.ingress.local:"$INGRESS_HTTP_PORT"/

curl --resolve api.ingress.local:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://api.ingress.local:"$INGRESS_HTTP_PORT"/
```

The exported values say that the tunnel is listening on this host
(`127.0.0.1`) at port `8080`. Each `--resolve` entry means
`hostname:port:address`: curl connects to `127.0.0.1:8080`, but sends the
hostname from the URL. This exercise deliberately changes that hostname so
NGINX selects a different host rule without requiring real DNS records.

## 5. Progressive Hints

1. Both hostnames can resolve to the same IP.
2. The request hostname, not the destination IP alone, selects the backend.
3. A backend port may be selected by name instead of number.

## 6. Expected Result

The first request reaches the frontend. The second reaches the quote API.

## 7. Common Errors

### Both requests reach the same backend

Check the two `host` values and verify the curl URLs differ.

### Direct IP request returns the wrong page

This request does not provide the intended host rule:

```bash
curl "http://$INGRESS_HOST:$INGRESS_HTTP_PORT"
```

Use `--resolve` so the Host header is correct. If curl reports `Connection
refused`, restart the port-forward shown in section 4.

### Named port not found

```bash
kubectl get service frontend quote-api -n ingress-lab -o yaml
```

Verify both Services expose a port named `http`.

## 8. Completed Solution

```bash
kubectl delete ingress host-routing -n ingress-lab --ignore-not-found
kubectl apply -f exercises/02-host-based-routing/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/02-host-based-routing/solution/ingress.yaml
```
