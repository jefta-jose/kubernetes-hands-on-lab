#!/usr/bin/env bash
set -euo pipefail

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is required by this script."
  exit 1
fi

if kind get clusters | grep -qx "services-lab"; then
  echo "The kind cluster services-lab already exists."
else
  kind create cluster --config cluster/kind-cluster.yaml
fi

kubectl wait --for=condition=Ready node --all --timeout=180s
kubectl get nodes -o wide
