#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-readiness

kubectl wait --for=condition=Ready pod/ready-backend -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/service-client -n "$ns" --timeout=180s

if kubectl wait --for=condition=Ready pod/unready-backend -n "$ns" --timeout=8s >/dev/null 2>&1; then
  echo "FAIL: unready-backend unexpectedly became ready"
  exit 1
fi

for _ in 1 2 3 4; do
  response="$(kubectl exec -n "$ns" service-client -- curl -s http://readiness-demo)"
  test "$response" = "ready-backend"
done

ready_endpoints="$(
  kubectl get endpointslice -n "$ns" \
    -l kubernetes.io/service-name=readiness-demo \
    -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' |
  sed '/^$/d' |
  wc -l |
  tr -d ' '
)"

test "$ready_endpoints" -eq 1
echo "PASS: only the ready Pod receives Service traffic"
