#!/usr/bin/env bash
set -euo pipefail

echo "== Nodes =="
kubectl get nodes -o wide

echo
echo "== Envoy Gateway =="
kubectl get deployment,pods -n envoy-gateway-system

echo
echo "== Gateway API CRDs =="
kubectl get crd gatewayclasses.gateway.networking.k8s.io gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io

echo
echo "== Gateway resources =="
kubectl get gatewayclass,gateway,httproute -A 2>/dev/null || true

echo
echo "== Lab applications =="
kubectl get deployment,service -n gateway-lab
kubectl get deployment,service -n shared-services
