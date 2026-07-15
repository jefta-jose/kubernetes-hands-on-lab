#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-headless --ignore-not-found
