#!/usr/bin/env bash
set -euo pipefail

namespaces=(
  service-lab-pods
  service-lab-clusterip
  service-lab-ports
  service-lab-dns
  service-lab-dns-client
  service-lab-readiness
  service-lab-nodeport
  service-lab-headless
  service-lab-alias
  service-lab-final
)

for namespace in "${namespaces[@]}"; do
  kubectl delete namespace "$namespace" --ignore-not-found --wait=false
done

echo "Cleanup requests submitted."
