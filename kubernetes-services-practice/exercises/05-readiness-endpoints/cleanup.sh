#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-readiness --ignore-not-found
