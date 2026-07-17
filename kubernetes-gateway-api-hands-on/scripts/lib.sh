#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runtime_dir="$repo_root/.runtime"
mkdir -p "$runtime_dir"

gateway_service() {
  local gateway_namespace="$1"
  local gateway_name="$2"

  kubectl get service \
    --namespace envoy-gateway-system \
    --selector="gateway.envoyproxy.io/owning-gateway-namespace=${gateway_namespace},gateway.envoyproxy.io/owning-gateway-name=${gateway_name}" \
    -o jsonpath='{.items[0].metadata.name}'
}

wait_for_gateway() {
  local namespace="$1"
  local name="$2"
  kubectl wait --for=condition=Programmed "gateway/${name}" -n "$namespace" --timeout=5m
}

start_test_forward() {
  local gateway_namespace="$1"
  local gateway_name="$2"
  local mapping="$3"
  local local_port="${mapping%%:*}"
  local service_name
  service_name="$(gateway_service "$gateway_namespace" "$gateway_name")"

  if [[ -z "$service_name" ]]; then
    echo "Could not find the Envoy Service for ${gateway_namespace}/${gateway_name}." >&2
    return 1
  fi

  kubectl -n envoy-gateway-system port-forward "service/${service_name}" "$mapping" \
    >"$runtime_dir/test-forward-${local_port}.log" 2>&1 &
  TEST_FORWARD_PID=$!
  export TEST_FORWARD_PID

  for _ in $(seq 1 30); do
    if grep -q "Forwarding from" "$runtime_dir/test-forward-${local_port}.log"; then
      return 0
    fi
    if ! kill -0 "$TEST_FORWARD_PID" >/dev/null 2>&1; then
      cat "$runtime_dir/test-forward-${local_port}.log" >&2
      return 1
    fi
    sleep 1
  done

  cat "$runtime_dir/test-forward-${local_port}.log" >&2
  return 1
}

stop_test_forward() {
  if [[ -n "${TEST_FORWARD_PID:-}" ]] && kill -0 "$TEST_FORWARD_PID" >/dev/null 2>&1; then
    kill "$TEST_FORWARD_PID" >/dev/null 2>&1 || true
    wait "$TEST_FORWARD_PID" 2>/dev/null || true
  fi
}

assert_contains() {
  local actual="$1"
  local expected="$2"
  local message="$3"
  if [[ "$actual" != *"$expected"* ]]; then
    echo "FAILED: $message" >&2
    echo "Expected response to contain: $expected" >&2
    echo "Actual response: $actual" >&2
    return 1
  fi
  echo "PASS: $message"
}
