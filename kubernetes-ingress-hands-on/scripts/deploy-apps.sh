#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$PROJECT_ROOT/shared/namespace.yaml"
kubectl apply -f "$PROJECT_ROOT/shared/apps.yaml"

for deployment in frontend quote-api quiz-api session-app custom-404; do
  kubectl rollout status \
    deployment/"$deployment" \
    -n ingress-lab \
    --timeout=180s
done

echo
kubectl get pods,services -n ingress-lab
