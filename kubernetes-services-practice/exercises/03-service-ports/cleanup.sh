#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-ports --ignore-not-found
