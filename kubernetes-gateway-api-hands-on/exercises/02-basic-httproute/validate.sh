#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/02-basic-httproute/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8082:80

response="$(curl -s -H 'Host: basic.gateway.local' http://127.0.0.1:8082/)"
assert_contains "$response" '"app":"stable"' "basic route reaches stable"
assert_contains "$response" '"path":"/"' "request path is preserved"
