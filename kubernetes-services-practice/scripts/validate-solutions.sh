#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

while IFS= read -r -d '' file; do
  echo "Validating ${file#$project_root/}"

  if grep -q '________' "$file"; then
    echo "ERROR: solution contains an unfinished blank"
    status=1
    continue
  fi

  if ! kubectl apply --dry-run=client --validate=false -f "$file" >/dev/null; then
    echo "ERROR: kubectl could not parse $file"
    status=1
  fi
done < <(find "$project_root/exercises" -name solution.yaml -print0 | sort -z)

if [[ "$status" -ne 0 ]]; then
  exit "$status"
fi

echo "All solution manifests passed local validation."
