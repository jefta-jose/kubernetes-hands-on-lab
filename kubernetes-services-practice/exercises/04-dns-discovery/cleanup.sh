#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace service-lab-dns service-lab-dns-client --ignore-not-found
