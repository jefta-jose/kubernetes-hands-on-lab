#!/usr/bin/env bash
set -euo pipefail

ns=service-lab-headless

kubectl rollout status deployment/peer-api -n "$ns" --timeout=180s
kubectl wait --for=condition=Ready pod/dns-client -n "$ns" --timeout=180s

cluster_ip="$(kubectl get svc peer-api -n "$ns" -o jsonpath='{.spec.clusterIP}')"
test "$cluster_ip" = "None"

pod_count="$(kubectl get pods -n "$ns" -l app=peer-api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' | sed '/^$/d' | wc -l | tr -d ' ')"
dns_output="$(kubectl exec -n "$ns" dns-client -- nslookup peer-api)"

for pod_ip in $(kubectl get pods -n "$ns" -l app=peer-api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}'); do
  grep -q "$pod_ip" <<<"$dns_output"
done

test "$pod_count" -eq 3
echo "PASS: headless DNS resolves directly to all ${pod_count} Pod IPs"
