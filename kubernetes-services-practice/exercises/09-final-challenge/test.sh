#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-final
expected=stable-networking-for-ephemeral-pods

kubectl rollout status deployment/quote-api -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/final-client -n "$ns" --timeout=180s

stable_response="$(kubectl exec -n "$ns" final-client -- curl -s http://quote-api)"
test "$stable_response" = "$expected"

cluster_ip="$(kubectl get svc quote-api -n "$ns" -o jsonpath='{.spec.clusterIP}')"
test -n "$cluster_ip"
test "$cluster_ip" != "None"

headless_ip="$(kubectl get svc quote-api-headless -n "$ns" -o jsonpath='{.spec.clusterIP}')"
test "$headless_ip" = "None"

node_port="$(kubectl get svc quote-api-public -n "$ns" -o jsonpath='{.spec.ports[0].nodePort}')"
test "$node_port" = "30081"

ready_endpoints="$(
  kubectl get endpointslice -n "$ns" \
    -l kubernetes.io/service-name=quote-api \
    -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' |
  sed '/^$/d' |
  wc -l |
  tr -d ' '
)"
test "$ready_endpoints" -eq 3

dns_output="$(kubectl exec -n "$ns" final-client -- nslookup quote-api-headless)"
for pod_ip in $(kubectl get pods -n "$ns" -l app=quote-api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}'); do
  grep -q "$pod_ip" <<<"$dns_output"
done

echo "PASS: final challenge combines stable DNS, readiness, EndpointSlices, headless discovery, and NodePort"
