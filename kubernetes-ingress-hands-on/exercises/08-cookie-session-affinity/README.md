# Exercise 08 — Cookie-Based Session Affinity

## 1. Concept

Ingress operates at HTTP Layer 7 and can use cookies to keep a client on the same backend Pod. This behaviour is controller-specific and is configured here using ingress-nginx annotations.

## 2. Task

Configure:

- Affinity mode: `cookie`
- Cookie name: `INGRESS_LAB_SESSION`

## 3. Incomplete File

```bash
cp exercises/08-cookie-session-affinity/exercise/ingress.yaml \
  /tmp/08-sticky-session.yaml
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/08-sticky-session.yaml
export INGRESS_IP="$(minikube ip)"
rm -f /tmp/ingress-lab-cookies.txt

curl -i \
  --resolve sticky.ingress.local:80:"$INGRESS_IP" \
  -c /tmp/ingress-lab-cookies.txt \
  http://sticky.ingress.local/
```

Repeat requests using the stored cookie:

```bash
for i in 1 2 3 4 5; do
  curl -s \
    --resolve sticky.ingress.local:80:"$INGRESS_IP" \
    -b /tmp/ingress-lab-cookies.txt \
    http://sticky.ingress.local/ |
  grep -o 'Pod: [^<]*'
done
```

## 5. Progressive Hints

1. The affinity annotation value is a lowercase HTTP state mechanism.
2. The cookie name is an arbitrary identifier chosen for this exercise.
3. These annotation keys are specific to ingress-nginx.

## 6. Expected Result

The response sets `INGRESS_LAB_SESSION`. Repeated requests with the cookie show the same Pod name.

## 7. Common Errors

### No `Set-Cookie` header

Check the annotations:

```bash
kubectl get ingress sticky-session -n ingress-lab -o yaml
```

### Requests still move between Pods

Confirm the cookie file exists and is passed with `-b`.

### Controller ignores annotations

This exercise requires the ingress-nginx controller selected by the `nginx` IngressClass.

## 8. Completed Solution

```bash
kubectl delete ingress sticky-session -n ingress-lab --ignore-not-found
kubectl apply -f exercises/08-cookie-session-affinity/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/08-cookie-session-affinity/solution/ingress.yaml
rm -f /tmp/ingress-lab-cookies.txt
```
