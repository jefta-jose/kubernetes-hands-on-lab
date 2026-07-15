#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-final --ignore-not-found
