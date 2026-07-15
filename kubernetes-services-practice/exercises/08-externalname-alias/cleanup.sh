#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-alias --ignore-not-found
