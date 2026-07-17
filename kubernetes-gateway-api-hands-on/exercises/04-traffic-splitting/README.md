# Exercise 4 — Weighted Traffic Splitting

## 1. Concept

A single HTTPRoute rule can contain multiple backends. Their relative `weight` values control the requested traffic distribution. Weights are proportions, not mandatory percentages.

## 2. Task

For `split.gateway.local`, send traffic in a 90:10 ratio:

```text
stable -> weight 90
canary -> weight 10
```

## 3. Incomplete file

```bash
cat exercise/route.yaml
```

## 4. Run and test

```bash
kubectl apply -f exercise/route.yaml
../../scripts/forward-gateway.sh gateway-lab lab-gateway 8080:80

for i in $(seq 1 100); do
  curl -s -H 'Host: split.gateway.local' http://127.0.0.1:8080/
done | grep -o '"app":"[^"]*"' | sort | uniq -c
```

## 5. Progressive hints

**Hint 1:** Both backends belong in the same `backendRefs` list.

**Hint 2:** `90` and `10` are equivalent in ratio to `9` and `1`.

**Hint 3:** A small request sample will not produce an exact ratio because each routing decision is probabilistic.

## 6. Expected result

Most responses should come from `stable`, and a smaller number should come from `canary`.

## 7. Common errors and troubleshooting

### Traffic is split evenly

Confirm both `weight` fields are present under their corresponding backend references.

### Canary never appears

Send a larger sample and inspect the live Route:

```bash
kubectl get httproute split-route -n gateway-lab -o yaml
```

Also confirm the canary Service has endpoints:

```bash
kubectl get endpoints canary -n gateway-lab
```

### Expecting exactly 90 responses

Weights describe the long-run proportion. They do not guarantee an exact count in each set of 100 requests.

## 8. Completed solution

```bash
kubectl apply -f solution/route.yaml
./validate.sh
```
