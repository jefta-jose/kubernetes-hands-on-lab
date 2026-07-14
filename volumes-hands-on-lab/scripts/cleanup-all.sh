#!/usr/bin/env bash
set -euo pipefail

namespace="volumes-lab"

if kubectl get namespace "${namespace}" >/dev/null 2>&1; then
  kubectl delete namespace "${namespace}"
  echo "Deleted namespace ${namespace}."
else
  echo "Namespace ${namespace} does not exist. Nothing to clean up."
fi
