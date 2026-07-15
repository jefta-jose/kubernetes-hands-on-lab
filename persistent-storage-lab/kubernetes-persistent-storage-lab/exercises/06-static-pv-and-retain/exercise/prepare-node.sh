#!/usr/bin/env bash
set -euo pipefail
minikube ssh -- "sudo mkdir -p /data/pv-lab-retain && sudo chmod 0777 /data/pv-lab-retain"
