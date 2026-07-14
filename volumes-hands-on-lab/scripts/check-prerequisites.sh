#!/usr/bin/env bash
set -euo pipefail

required=(kubectl curl)
missing=0

for command_name in "${required[@]}"; do
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf "OK: %s found at %s\n" "${command_name}" "$(command -v "${command_name}")"
  else
    printf "MISSING: %s\n" "${command_name}"
    missing=1
  fi
done

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "ERROR: kubectl cannot reach a Kubernetes cluster."
  echo "Enable Kubernetes in Docker Desktop or configure your kubeconfig."
  missing=1
else
  echo "OK: Kubernetes cluster is reachable."
fi

if [[ "${missing}" -ne 0 ]]; then
  exit 1
fi

echo "Prerequisite check passed."
