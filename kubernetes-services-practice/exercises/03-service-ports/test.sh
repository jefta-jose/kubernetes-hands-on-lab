#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-ports

kubectl rollout status deployment/ports-demo -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/service-client -n "$ns" --timeout=180s

response="$(kubectl exec -n "$ns" service-client -- curl -s http://ports-demo)"
test "$response" = "service-port-80-to-container-port-8080"

endpoint_port="$(
  kubectl get endpointslice -n "$ns" \
    -l kubernetes.io/service-name=ports-demo \
    -o jsonpath='{.items[0].ports[0].port}'
)"

test "$endpoint_port" = "8080"
echo "PASS: Service port 80 maps to backend port ${endpoint_port}"
