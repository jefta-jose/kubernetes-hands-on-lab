#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-nodeport

kubectl rollout status deployment/public-api -n "$ns" --timeout=180s

service_type="$(kubectl get svc public-api -n "$ns" -o jsonpath='{.spec.type}')"
node_port="$(kubectl get svc public-api -n "$ns" -o jsonpath='{.spec.ports[0].nodePort}')"

test "$service_type" = "NodePort"
test "$node_port" = "30080"

response="$(
  kubectl run nodeport-test-client \
    --rm -i --restart=Never \
    --image=curlimages/curl:8.10.1 \
    -n "$ns" \
    -- curl -s http://public-api
)"

test "$response" = "public-api"
echo "PASS: NodePort Service uses node port ${node_port} and reaches the backends"
