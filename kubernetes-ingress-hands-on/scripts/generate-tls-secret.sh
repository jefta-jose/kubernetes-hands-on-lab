#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-}"
SECRET_NAME="${2:-}"
NAMESPACE="${3:-ingress-lab}"

if [[ -z "$HOST" || -z "$SECRET_NAME" ]]; then
  echo "Usage: $0 <hostname> <secret-name> [namespace]"
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

openssl req \
  -x509 \
  -newkey rsa:2048 \
  -nodes \
  -sha256 \
  -days 365 \
  -keyout "$TEMP_DIR/tls.key" \
  -out "$TEMP_DIR/tls.crt" \
  -subj "/CN=$HOST" \
  -addext "subjectAltName=DNS:$HOST"

kubectl create secret tls "$SECRET_NAME" \
  --namespace "$NAMESPACE" \
  --cert="$TEMP_DIR/tls.crt" \
  --key="$TEMP_DIR/tls.key" \
  --dry-run=client \
  -o yaml |
kubectl apply -f -

echo "Created or updated Secret '$SECRET_NAME' for '$HOST' in namespace '$NAMESPACE'."
