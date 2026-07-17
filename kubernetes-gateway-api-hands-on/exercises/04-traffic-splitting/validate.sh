#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/04-traffic-splitting/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8084:80

stable=0
canary=0
for _ in $(seq 1 120); do
  response="$(curl -s -H 'Host: split.gateway.local' http://127.0.0.1:8084/)"
  if [[ "$response" == *'"app":"stable"'* ]]; then
    stable=$((stable + 1))
  elif [[ "$response" == *'"app":"canary"'* ]]; then
    canary=$((canary + 1))
  else
    echo "Unexpected response: $response" >&2
    exit 1
  fi
done

[[ "$stable" -gt "$canary" ]]
[[ "$canary" -gt 0 ]]
echo "PASS: weighted split observed. stable=$stable canary=$canary"
