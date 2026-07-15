#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-clusterip

kubectl rollout status deployment/quote -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/service-client -n "$ns" --timeout=180s

response="$(kubectl exec -n "$ns" service-client -- curl -s http://quote)"
test "$response" = "quote-service"

endpoint_count="$(
  kubectl get endpointslice -n "$ns" \
    -l kubernetes.io/service-name=quote \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' |
  sed '/^$/d' |
  wc -l |
  tr -d ' '
)"

test "$endpoint_count" -eq 3
echo "PASS: ClusterIP quote is stable and has ${endpoint_count} endpoints"
