#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/lib.sh"

gateway_namespace="${1:-gateway-lab}"
gateway_name="${2:-lab-gateway}"
shift 2 || true
mappings=("${@:-8080:80}")

service_name="$(gateway_service "$gateway_namespace" "$gateway_name")"
if [[ -z "$service_name" ]]; then
  echo "No Envoy Service found for ${gateway_namespace}/${gateway_name}." >&2
  echo "Check: kubectl get gateway -A" >&2
  exit 1
fi

first_mapping="${mappings[0]}"
first_port="${first_mapping%%:*}"
pid_file="$runtime_dir/forward-${first_port}.pid"
log_file="$runtime_dir/forward-${first_port}.log"

if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" >/dev/null 2>&1; then
  echo "A port-forward using local port $first_port is already running."
  exit 0
fi

kubectl -n envoy-gateway-system port-forward "service/${service_name}" "${mappings[@]}" >"$log_file" 2>&1 &
pid=$!
echo "$pid" >"$pid_file"

for _ in $(seq 1 30); do
  if grep -q "Forwarding from" "$log_file"; then
    echo "Port-forward started with PID $pid: ${mappings[*]}"
    echo "Log: $log_file"
    exit 0
  fi
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    cat "$log_file" >&2
    rm -f "$pid_file"
    exit 1
  fi
  sleep 1
done

cat "$log_file" >&2
kill "$pid" >/dev/null 2>&1 || true
rm -f "$pid_file"
exit 1
