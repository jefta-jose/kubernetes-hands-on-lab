#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r -d '' file; do
  echo "Applying ${file#$project_root/}"
  kubectl apply -f "$file"
done < <(find "$project_root/exercises" -name solution.yaml -print0 | sort -z)

echo "Waiting briefly for workloads to start..."
sleep 5
kubectl get pods -A
