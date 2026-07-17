# Solution Validation Notes

The solution manifests are standard Kubernetes YAML and contain no learning placeholders.

Quick static checks:

```bash
grep -R "________" exercises/*/solution && exit 1 || true
```

Client-side validation against a running cluster:

```bash
for file in exercises/*/solution/*.yaml; do
  kubectl apply --dry-run=client -f "$file" >/dev/null
done
```

Server-side schema validation:

```bash
for file in exercises/*/solution/*.yaml; do
  kubectl apply --dry-run=server -f "$file" >/dev/null
done
```
