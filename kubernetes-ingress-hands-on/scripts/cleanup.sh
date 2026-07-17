#!/usr/bin/env bash
set -euo pipefail

PROFILE="${MINIKUBE_PROFILE:-minikube}"

kubectl delete namespace ingress-lab --ignore-not-found=true

if [[ "${1:-}" == "--delete-cluster" ]]; then
  minikube delete -p "$PROFILE"
else
  echo "Deleted the ingress-lab namespace."
  echo "Minikube profile '$PROFILE' was kept."
fi
