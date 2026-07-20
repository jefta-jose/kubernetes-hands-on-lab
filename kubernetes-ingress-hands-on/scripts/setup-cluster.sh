#!/usr/bin/env bash
set -euo pipefail

PROFILE="${MINIKUBE_PROFILE:-minikube}"

if minikube status -p "$PROFILE" >/dev/null 2>&1; then
  echo "Minikube profile '$PROFILE' is already running."
else
  echo "Starting Minikube profile '$PROFILE' with the Docker driver..."
  minikube start -p "$PROFILE" --driver=docker
fi

echo "Enabling the ingress add-on..."
minikube addons enable ingress -p "$PROFILE"

echo "Waiting for the ingress controller..."
kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Available \
  deployment/ingress-nginx-controller \
  --timeout=240s

"$(dirname "$0")/deploy-apps.sh"

echo
echo "Ingress lab is ready."
echo "In a separate terminal, expose the ingress controller to your host:"
echo "kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80 8443:443"
