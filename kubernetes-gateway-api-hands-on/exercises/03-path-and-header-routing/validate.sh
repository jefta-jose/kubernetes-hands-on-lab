#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/03-path-and-header-routing/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8083:80

base=(-s -H 'Host: routing.gateway.local')
assert_contains "$(curl "${base[@]}" http://127.0.0.1:8083/)" '"app":"stable"' "catch-all reaches stable"
assert_contains "$(curl "${base[@]}" http://127.0.0.1:8083/auth/login)" '"app":"auth"' "/auth reaches auth"
assert_contains "$(curl "${base[@]}" http://127.0.0.1:8083/orders/42)" '"app":"orders"' "/orders reaches orders"
assert_contains "$(curl "${base[@]}" -H 'X-Release: canary' http://127.0.0.1:8083/)" '"app":"canary"' "header reaches canary"
