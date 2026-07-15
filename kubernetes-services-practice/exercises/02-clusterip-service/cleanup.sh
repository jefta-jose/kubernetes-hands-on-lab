#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-clusterip --ignore-not-found
