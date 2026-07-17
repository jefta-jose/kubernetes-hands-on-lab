#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for local_port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8090 8443 9443; do
  "$repo_root/scripts/stop-forward.sh" "$local_port" >/dev/null 2>&1 || true
done

kubectl delete gateway,httproute -A --all --ignore-not-found=true
kubectl delete referencegrant -A --all --ignore-not-found=true
kubectl delete gatewayclass eg --ignore-not-found=true
kubectl delete secret gateway-lab-tls -n gateway-lab --ignore-not-found=true
kubectl delete secret final-tls -n infra --ignore-not-found=true

kubectl apply -f "$repo_root/platform/namespaces.yaml"
kubectl apply -f "$repo_root/platform/apps.yaml"

echo "Exercise resources reset. Envoy Gateway and application workloads remain installed."
