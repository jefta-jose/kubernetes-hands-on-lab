#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/05-request-filters/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8085:80

response="$(curl -s -H 'Host: filters.gateway.local' http://127.0.0.1:8085/legacy/users)"
assert_contains "$response" '"path":"/api/users"' "prefix is rewritten"
assert_contains "$response" '"x-gateway-lab":"rewritten"' "Gateway sets request header"
