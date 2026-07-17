#!/usr/bin/env bash
set -euo pipefail

provider="${1:-kind}"
required=(docker kubectl helm curl openssl)

if [[ "$provider" == "kind" ]]; then
  required+=(kind)
elif [[ "$provider" == "minikube" ]]; then
  required+=(minikube)
else
  echo "Unsupported provider: $provider. Use kind or minikube." >&2
  exit 1
fi

missing=0
for command_name in "${required[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but the daemon is not reachable." >&2
  exit 1
fi

echo "All required tools are available."
