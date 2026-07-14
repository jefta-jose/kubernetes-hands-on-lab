#!/usr/bin/env bash
set -euo pipefail

echo "== StorageClasses =="
kubectl get sc

echo
echo "== PersistentVolumeClaims =="
kubectl get pvc -A || true

echo
echo "== PersistentVolumes =="
kubectl get pv || true

echo
echo "== CSI drivers =="
kubectl get csidriver || true
