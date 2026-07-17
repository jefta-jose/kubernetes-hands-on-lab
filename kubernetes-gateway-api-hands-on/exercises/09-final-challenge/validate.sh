#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/lib.sh"

HTTP_PID=""
HTTPS_PID=""
cleanup() {
  [[ -z "$HTTP_PID" ]] || kill "$HTTP_PID" >/dev/null 2>&1 || true
  [[ -z "$HTTPS_PID" ]] || kill "$HTTPS_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
"$repo_root/scripts/create-tls-secret.sh" infra final-tls app.final.gateway.local
kubectl apply -f "$repo_root/exercises/09-final-challenge/solution/"
wait_for_gateway infra production-gateway

service_name="$(gateway_service infra production-gateway)"
kubectl -n envoy-gateway-system port-forward "service/${service_name}" 8090:80 >"$runtime_dir/final-http.log" 2>&1 &
HTTP_PID=$!
kubectl -n envoy-gateway-system port-forward "service/${service_name}" 9443:443 >"$runtime_dir/final-https.log" 2>&1 &
HTTPS_PID=$!
sleep 3

status="$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: app.final.gateway.local' http://127.0.0.1:8090/)"
[[ "$status" == "301" ]]
echo "PASS: HTTP redirects with 301"

default_response="$(curl -sk --resolve app.final.gateway.local:9443:127.0.0.1 https://app.final.gateway.local:9443/)"
assert_contains "$default_response" '"app":"shared-api"' "default HTTPS route reaches shared-api"

canary_response="$(curl -sk --resolve app.final.gateway.local:9443:127.0.0.1 -H 'X-Release: canary' https://app.final.gateway.local:9443/api/users)"
assert_contains "$canary_response" '"app":"canary"' "header forces canary"

rewrite_response="$(curl -sk --resolve app.final.gateway.local:9443:127.0.0.1 https://app.final.gateway.local:9443/legacy/users)"
assert_contains "$rewrite_response" '"app":"stable"' "legacy route reaches stable"
assert_contains "$rewrite_response" '"path":"/api/users"' "legacy prefix is rewritten"

marker="final-mirror-$(date +%s)"
curl -sk --resolve app.final.gateway.local:9443:127.0.0.1 "https://app.final.gateway.local:9443/api/${marker}" >/dev/null
for _ in $(seq 1 20); do
  if kubectl logs deployment/mirror -n gateway-lab --since=2m | grep -q "$marker"; then
    echo "PASS: /api request was mirrored"
    break
  fi
  sleep 1
done
kubectl logs deployment/mirror -n gateway-lab --since=2m | grep -q "$marker"

for route in final-http-redirect final-application; do
  resolved="$(kubectl get httproute "$route" -n team-a -o jsonpath='{range .status.parents[0].conditions[?(@.type=="ResolvedRefs")]}{.status}{end}')"
  [[ "$resolved" == "True" ]]
done
echo "PASS: final Route references are resolved"
