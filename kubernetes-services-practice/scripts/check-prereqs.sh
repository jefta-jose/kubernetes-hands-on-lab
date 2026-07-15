#!/usr/bin/env bash
set -euo pipefail

required=(docker kubectl curl)
optional=(kind)

missing=0

for command_name in "${required[@]}"; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf "OK      %s\n" "$command_name"
  else
    printf "MISSING %s\n" "$command_name"
    missing=1
  fi
done

for command_name in "${optional[@]}"; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf "OK      %s\n" "$command_name"
  else
    printf "OPTIONAL %s is not installed\n" "$command_name"
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Install the missing required commands before continuing."
  exit 1
fi

echo "Required prerequisites are available."
