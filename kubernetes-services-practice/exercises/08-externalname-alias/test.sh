#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-alias

kubectl rollout status deployment/backend -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/alias-client -n "$ns" --timeout=180s

service_type="$(kubectl get svc inventory-api -n "$ns" -o jsonpath='{.spec.type}')"
external_name="$(kubectl get svc inventory-api -n "$ns" -o jsonpath='{.spec.externalName}')"

test "$service_type" = "ExternalName"
test "$external_name" = "backend.service-lab-alias.svc.cluster.local"

response="$(kubectl exec -n "$ns" alias-client -- wget -qO- http://inventory-api)"
test "$response" = "inventory-backend"

echo "PASS: inventory-api aliases ${external_name}"
