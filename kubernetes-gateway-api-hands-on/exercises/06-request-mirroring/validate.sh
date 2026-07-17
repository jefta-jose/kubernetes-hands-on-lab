#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"
trap stop_test_forward EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl apply -f "$repo_root/exercises/06-request-mirroring/solution/"
wait_for_gateway gateway-lab lab-gateway
start_test_forward gateway-lab lab-gateway 8086:80

marker="mirror-check-$(date +%s)"
response="$(curl -s -H 'Host: mirror.gateway.local' "http://127.0.0.1:8086/${marker}")"
assert_contains "$response" '"app":"stable"' "primary response comes from stable"

for _ in $(seq 1 20); do
  if kubectl logs deployment/mirror -n gateway-lab --since=2m | grep -q "$marker"; then
    echo "PASS: mirrored request appeared in mirror logs"
    exit 0
  fi
  sleep 1
done

echo "FAILED: mirrored request did not appear in mirror logs" >&2
exit 1
