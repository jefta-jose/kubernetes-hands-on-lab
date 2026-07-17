#!/usr/bin/env bash
set -euo pipefail

namespace="${1:-gateway-lab}"
secret_name="${2:-gateway-lab-tls}"
hostname="${3:-secure.gateway.local}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/openssl.cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = v3_req
prompt = no

[dn]
CN = ${hostname}

[v3_req]
subjectAltName = @alt_names
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = ${hostname}
EOF

openssl req \
  -x509 \
  -nodes \
  -newkey rsa:2048 \
  -days 365 \
  -keyout "$tmp_dir/tls.key" \
  -out "$tmp_dir/tls.crt" \
  -config "$tmp_dir/openssl.cnf" \
  -extensions v3_req >/dev/null 2>&1

kubectl create secret tls "$secret_name" \
  --namespace "$namespace" \
  --cert "$tmp_dir/tls.crt" \
  --key "$tmp_dir/tls.key" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "Created TLS Secret ${namespace}/${secret_name} for ${hostname}."
