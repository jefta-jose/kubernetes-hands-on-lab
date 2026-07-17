#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/08-cross-namespace-routing/solution/"
wait_for_gateway infra shared-gateway
start_test_forward infra shared-gateway 8088:80

response="$(curl -s -H 'Host: team-a.shared.gateway.local' http://127.0.0.1:8088/)"
assert_contains "$response" '"app":"shared-api"' "cross-namespace backend is authorized"

resolved="$(kubectl get httproute team-a-route -n team-a -o jsonpath='{range .status.parents[0].conditions[?(@.type=="ResolvedRefs")]}{.status}{end}')"
[[ "$resolved" == "True" ]]
echo "PASS: Route references are resolved."
