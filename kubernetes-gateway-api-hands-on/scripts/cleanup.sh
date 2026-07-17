#!/usr/bin/env bash
set -euo pipefail

mode="${1:-resources}"
provider="${2:-kind}"
cluster_name="${CLUSTER_NAME:-gateway-api-lab}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$mode" == "cluster" ]]; then
  case "$provider" in
    kind)
      kind delete cluster --name "$cluster_name"
      ;;
    minikube)
      minikube delete -p "$cluster_name"
      ;;
    *)
      echo "Unsupported provider: $provider" >&2
      exit 1
      ;;
  esac
  exit 0
fi

"$repo_root/scripts/reset.sh" || true
kubectl delete -f "$repo_root/platform/apps.yaml" --ignore-not-found=true || true
kubectl delete -f "$repo_root/platform/namespaces.yaml" --ignore-not-found=true || true
helm uninstall eg -n envoy-gateway-system || true

echo "Removed lab resources and Envoy Gateway. The Kubernetes cluster still exists."
