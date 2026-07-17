#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

kubectl apply -f "$repo_root/exercises/01-gatewayclass-and-gateway/solution/"
kubectl wait --for=condition=Accepted gatewayclass/eg --timeout=5m
kubectl wait --for=condition=Programmed gateway/lab-gateway -n gateway-lab --timeout=5m

controller="$(kubectl get gatewayclass eg -o jsonpath='{.spec.controllerName}')"
listener="$(kubectl get gateway lab-gateway -n gateway-lab -o jsonpath='{.spec.listeners[0].protocol}:{.spec.listeners[0].port}')"

[[ "$controller" == "gateway.envoyproxy.io/gatewayclass-controller" ]]
[[ "$listener" == "HTTP:80" ]]

echo "PASS: GatewayClass is accepted and lab-gateway is programmed."
