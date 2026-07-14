#!/usr/bin/env bash
set -euo pipefail

namespaces=(
  pv-lab-02
  pv-lab-03
  pv-lab-04
  pv-lab-05
  pv-lab-06
  pv-lab-07
  pv-lab-08
)

for namespace in "${namespaces[@]}"; do
  kubectl delete namespace "$namespace" --ignore-not-found --wait=true
 done

kubectl delete storageclass pv-lab-delayed --ignore-not-found
kubectl delete storageclass pv-lab-static --ignore-not-found
kubectl delete storageclass pv-lab-final --ignore-not-found
kubectl delete persistentvolume pv-lab-retain-pv --ignore-not-found --wait=true

if command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1; then
  minikube ssh -- "sudo rm -rf /data/pv-lab-retain" >/dev/null 2>&1 || true
fi

echo "All Kubernetes persistent-storage lab resources were removed."
