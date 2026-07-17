#!/usr/bin/env bash
set -euo pipefail

required=(docker kubectl minikube curl openssl)
missing=0

for command_name in "${required[@]}"; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf "OK      %s\n" "$command_name"
  else
    printf "MISSING %s\n" "$command_name"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo
  echo "Install the missing commands before continuing."
  exit 1
fi

echo
echo "All required commands are available."
