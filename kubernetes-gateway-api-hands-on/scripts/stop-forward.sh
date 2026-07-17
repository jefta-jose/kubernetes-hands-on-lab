#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
local_port="${1:-8080}"
pid_file="$repo_root/.runtime/forward-${local_port}.pid"

if [[ ! -f "$pid_file" ]]; then
  echo "No recorded port-forward for local port $local_port."
  exit 0
fi

pid="$(cat "$pid_file")"
if kill -0 "$pid" >/dev/null 2>&1; then
  kill "$pid"
  wait "$pid" 2>/dev/null || true
fi
rm -f "$pid_file"
echo "Stopped port-forward on local port $local_port."
