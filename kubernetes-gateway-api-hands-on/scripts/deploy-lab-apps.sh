#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$repo_root/platform/namespaces.yaml"
kubectl apply -f "$repo_root/platform/apps.yaml"

kubectl wait --for=condition=Available deployment --all -n gateway-lab --timeout=5m
kubectl wait --for=condition=Available deployment --all -n shared-services --timeout=5m

kubectl get pods,svc -n gateway-lab
kubectl get pods,svc -n shared-services
