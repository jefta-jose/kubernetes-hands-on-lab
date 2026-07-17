#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
"$repo_root/scripts/create-tls-secret.sh" gateway-lab gateway-lab-tls secure.gateway.local
kubectl apply -f "$repo_root/exercises/07-tls-termination/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8443:443

response="$(curl -sk --resolve secure.gateway.local:8443:127.0.0.1 https://secure.gateway.local:8443/)"
assert_contains "$response" '"app":"stable"' "HTTPS route reaches stable"
