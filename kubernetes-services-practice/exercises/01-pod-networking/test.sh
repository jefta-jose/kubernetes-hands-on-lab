#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-pods

kubectl wait --for=condition=Ready pod/echo-server -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/network-client -n "$ns" --timeout=180s

server_ip="$(kubectl get pod echo-server -n "$ns" -o jsonpath='{.status.podIP}')"
response="$(kubectl exec -n "$ns" network-client -- curl -s "http://${server_ip}:5678")"

test "$response" = "hello-from-pod"
echo "PASS: the client reached the server directly at ${server_ip}:5678"
