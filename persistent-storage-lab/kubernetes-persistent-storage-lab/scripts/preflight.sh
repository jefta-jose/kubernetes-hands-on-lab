#!/usr/bin/env bash
set -euo pipefail

required=(kubectl minikube python3)
for command_name in "${required[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $command_name" >&2
    exit 1
  fi
done

if ! minikube status >/dev/null 2>&1; then
  echo "ERROR: Minikube is not running." >&2
  echo "Start it with: minikube start --driver=docker --cpus=2 --memory=4096" >&2
  exit 1
fi

kubectl cluster-info >/dev/null

node_count="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$node_count" -lt 1 ]]; then
  echo "ERROR: no Kubernetes nodes are Ready." >&2
  exit 1
fi

default_sc="$(kubectl get sc -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' | head -n1)"
if [[ -z "$default_sc" ]]; then
  echo "ERROR: no default StorageClass was found." >&2
  exit 1
fi

provisioner="$(kubectl get sc "$default_sc" -o jsonpath='{.provisioner}')"
binding_mode="$(kubectl get sc "$default_sc" -o jsonpath='{.volumeBindingMode}')"

cat <<EOF
Preflight passed.

Cluster context : $(kubectl config current-context)
Nodes           : $node_count
Default class   : $default_sc
Provisioner     : $provisioner
Binding mode    : ${binding_mode:-Immediate}
EOF

if [[ "$provisioner" != "k8s.io/minikube-hostpath" ]]; then
  cat <<'EOF'

WARNING:
Exercises 05 and 08 use the Minikube host-path provisioner in their completed solutions.
Your cluster uses a different provisioner. Replace that solution value with the provisioner
reported above when running those exercises outside the reference Minikube setup.
EOF
fi

echo
echo "Current storage resources:"
kubectl get sc
kubectl get pv || true
