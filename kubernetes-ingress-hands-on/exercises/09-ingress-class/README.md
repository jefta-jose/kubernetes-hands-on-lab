# Exercise 09 — Select an IngressClass

## 1. Concept

`spec.ingressClassName` selects the IngressClass and therefore the controller responsible for reconciling an Ingress.

## 2. Task

Inspect the available classes and fill in the class created by the Minikube ingress add-on.

## 3. Incomplete File

List classes first:

```bash
kubectl get ingressclass
```

Then copy the exercise:

```bash
cp exercises/09-ingress-class/exercise/ingress.yaml \
  /tmp/09-ingress-class.yaml
```

## 4. Run and Test

```bash
kubectl apply -f /tmp/09-ingress-class.yaml
kubectl describe ingress class-selection -n ingress-lab

export INGRESS_IP="$(minikube ip)"
curl --resolve class.ingress.local:80:"$INGRESS_IP" \
  http://class.ingress.local/
```

## 5. Progressive Hints

1. The expected class name is visible under the `NAME` column.
2. The controller field typically contains `k8s.io/ingress-nginx`.
3. Use the IngressClass object name, not the controller identifier.

## 6. Expected Result

The ingress-nginx controller processes the object and routes the request to the frontend.

## 7. Common Errors

### Ingress remains unprocessed

```bash
kubectl get ingressclass
kubectl describe ingress class-selection -n ingress-lab
```

The class name may not exist.

### Confusing class name and controller value

Given:

```text
NAME    CONTROLLER
nginx   k8s.io/ingress-nginx
```

the Ingress uses `nginx`.

## 8. Completed Solution

```bash
kubectl delete ingress class-selection -n ingress-lab --ignore-not-found
kubectl apply -f exercises/09-ingress-class/solution/ingress.yaml
```

Clean up:

```bash
kubectl delete -f exercises/09-ingress-class/solution/ingress.yaml
```
