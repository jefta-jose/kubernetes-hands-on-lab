# Exercise 05 — Multiple Rules and Wildcard Hosts

## 1. Concept

One Ingress can contain several host rules. A wildcard such as `*.apps.ingress.local` matches one DNS label. An exact host rule takes precedence over a wildcard rule.

## 2. Task

Configure:

- Exact host `admin.apps.ingress.local` → `frontend`
- Wildcard host `*.apps.ingress.local` → `quote-api`

## 3. Incomplete File

```bash
cp exercises/05-multiple-rules-and-wildcards/exercise/ingress.yaml \
  /tmp/05-wildcard.yaml
```

Quote the wildcard hostname in YAML.

## 4. Run and Test

```bash
kubectl apply -f /tmp/05-wildcard.yaml
export INGRESS_IP="$(minikube ip)"

curl --resolve admin.apps.ingress.local:80:"$INGRESS_IP" \
  http://admin.apps.ingress.local/

curl --resolve dev.apps.ingress.local:80:"$INGRESS_IP" \
  http://dev.apps.ingress.local/

curl -i --resolve deep.dev.apps.ingress.local:80:"$INGRESS_IP" \
  http://deep.dev.apps.ingress.local/
```

## 5. Progressive Hints

1. YAML interprets `*` specially, so wrap the wildcard hostname in quotes.
2. The wildcard covers only one label.
3. The exact `admin` rule should win over the wildcard.

## 6. Expected Result

- `admin.apps.ingress.local` reaches the frontend.
- `dev.apps.ingress.local` reaches the quote API.
- `deep.dev.apps.ingress.local` does not match the one-label wildcard.

## 7. Common Errors

### YAML alias parsing error

Use:

```yaml
host: "*.apps.ingress.local"
```

not:

```yaml
host: *.apps.ingress.local
```

### Wildcard matches too much

It should not match the root domain or multiple subdomain levels.

### Exact host reaches wildcard backend

Inspect the rendered rules:

```bash
kubectl describe ingress wildcard-routing -n ingress-lab
```

## 8. Completed Solution

```bash
kubectl delete ingress wildcard-routing -n ingress-lab --ignore-not-found
kubectl apply -f exercises/05-multiple-rules-and-wildcards/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/05-multiple-rules-and-wildcards/solution/ingress.yaml
```
