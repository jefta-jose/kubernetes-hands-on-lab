#!/usr/bin/env bash
set -euo pipefail

echo "== StorageClasses =="
kubectl get storageclass

echo
echo "== PersistentVolumes =="
kubectl get persistentvolume

echo
echo "== Default StorageClass =="
kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\t"}{.provisioner}{"\n"}{end}'

echo
echo "== CSI drivers =="
kubectl get csidriver