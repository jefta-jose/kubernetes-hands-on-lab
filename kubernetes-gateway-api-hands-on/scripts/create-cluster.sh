#!/usr/bin/env bash
set -euo pipefail

provider="${1:-kind}"
cluster_name="${CLUSTER_NAME:-gateway-api-lab}"
kubernetes_version="${KUBERNETES_VERSION:-v1.35.0}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$provider" in
  kind)
    if kind get clusters 2>/dev/null | grep -qx "$cluster_name"; then
      echo "kind cluster $cluster_name already exists."
    else
      kind create cluster \
        --name "$cluster_name" \
        --image "kindest/node:${kubernetes_version}" \
        --config "$repo_root/kind-config.yaml"
    fi
    kubectl config use-context "kind-${cluster_name}" >/dev/null
    ;;
  minikube)
    if minikube status -p "$cluster_name" >/dev/null 2>&1; then
      echo "Minikube profile $cluster_name already exists."
    else
      minikube start \
        -p "$cluster_name" \
        --driver=docker \
        --nodes=3 \
        --kubernetes-version="$kubernetes_version"
    fi
    minikube profile "$cluster_name" >/dev/null
    ;;
  *)
    echo "Unsupported provider: $provider. Use kind or minikube." >&2
    exit 1
    ;;
esac

kubectl wait --for=condition=Ready nodes --all --timeout=5m
kubectl get nodes -o wide
