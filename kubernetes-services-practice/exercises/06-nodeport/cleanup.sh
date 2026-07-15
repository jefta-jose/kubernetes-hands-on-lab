#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-nodeport --ignore-not-found
