#!/usr/bin/env bash
set -euo pipefail

echo "== StorageClasses =="
kubectl get ________

echo
echo "== PersistentVolumes =="
kubectl get ________

echo
echo "== CSI drivers =="
kubectl get ________

echo
echo "== Default StorageClass =="
kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="________")]}{.metadata.name}{"\t"}{.provisioner}{"\n"}{end}'
