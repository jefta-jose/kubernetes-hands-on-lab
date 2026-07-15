#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r -d '' script; do
  echo
  echo "Running ${script#$project_root/}"
  "$script"
done < <(find "$project_root/exercises" -name test.sh -print0 | sort -z)
