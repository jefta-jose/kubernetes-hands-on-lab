#!/usr/bin/env bash
set -euo pipefail

server_ns=service-lab-dns
client_ns=service-lab-dns-client
fqdn=catalog.service-lab-dns.svc.cluster.local

kubectl rollout status deployment/catalog -n "$server_ns" --timeout=180s
kubectl wait --for=condition=Ready pod/dns-client -n "$client_ns" --timeout=180s

kubectl exec -n "$client_ns" dns-client -- nslookup "$fqdn" >/dev/null
response="$(kubectl exec -n "$client_ns" dns-client -- wget -qO- "http://${fqdn}")"

test "$response" = "catalog-v1"
echo "PASS: cross-namespace DNS discovery works through ${fqdn}"
