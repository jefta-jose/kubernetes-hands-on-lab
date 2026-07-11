# Final Challenge — Build a Multi-Volume Web Workload

## Scenario

You are building a small internal status page.

The workload must:

1. Read a title and message from a ConfigMap.
2. Read a display username from a Secret.
3. Read its own Pod name and namespace through the Downward API.
4. Combine those sources through one projected volume.
5. Use an init container to generate an HTML page.
6. Share the generated page with Nginx through an `emptyDir`.
7. Mount the Nginx site read-only.
8. Run an audit sidecar that writes events to a PersistentVolumeClaim.
9. Preserve the audit log when the Deployment Pod is replaced.
10. Expose the page through a ClusterIP Service.

This is a simplified production-style design:

```text
ConfigMap -------\
Secret -----------\
Downward API ------> projected volume
                         |
                         v
                  init page builder
                         |
                         v
                     emptyDir
                         |
                         v
                       Nginx

audit sidecar -----------------> PVC
```

## Task

Complete all manifests under `exercise/`.

The blanks cover:

- Resource names
- Volume types
- Claim access mode and size
- Projected sources
- Downward API fields
- Mount paths
- Read-only settings
- Deployment selector
- Service selector and port mapping

## Files

```text
exercise/
├── configmap.yaml
├── secret.yaml
├── pvc.yaml
├── deployment.yaml
└── service.yaml
```

## Run

```bash
kubectl create namespace volumes-lab --dry-run=client -o yaml | kubectl apply -f -
rm -rf /tmp/09
mkdir -p /tmp/09
cp exercise/*.yaml /tmp/09/
```

Complete the files:

```bash
nano /tmp/09/configmap.yaml
nano /tmp/09/secret.yaml
nano /tmp/09/pvc.yaml
nano /tmp/09/deployment.yaml
nano /tmp/09/service.yaml
```

Check blanks:

```bash
python3 ../../scripts/check-blanks.py /tmp/09
```

Validate:

```bash
kubectl apply --dry-run=client -f /tmp/09/
```

Apply:

```bash
kubectl apply -f /tmp/09/
kubectl rollout status deployment/volume-lab-web -n volumes-lab --timeout=120s
kubectl get pods,service,pvc -n volumes-lab
```

## Test the page

Port-forward the Service:

```bash
kubectl port-forward -n volumes-lab service/volume-lab-web 8080:80
```

In another terminal:

```bash
curl http://localhost:8080
```

The HTML should include:

- The configured title
- The configured message
- The Secret-derived username
- The current Pod name
- The namespace

## Test shared volume behavior

Find the Pod:

```bash
POD_NAME="$(kubectl get pods -n volumes-lab \
  -l app=volume-lab-web \
  -o jsonpath='{.items[0].metadata.name}')"
echo "${POD_NAME}"
```

Read the generated HTML from Nginx:

```bash
kubectl exec -n volumes-lab "${POD_NAME}" -c nginx -- cat /usr/share/nginx/html/index.html
```

Inspect init container completion:

```bash
kubectl get pod "${POD_NAME}" -n volumes-lab \
  -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}{"\n"}'
```

## Test PVC persistence

Read the audit log:

```bash
kubectl exec -n volumes-lab "${POD_NAME}" -c audit-writer -- tail -n 5 /audit/events.log
```

Delete the Pod:

```bash
kubectl delete pod "${POD_NAME}" -n volumes-lab
```

Wait for the Deployment to recreate it:

```bash
kubectl rollout status deployment/volume-lab-web -n volumes-lab --timeout=120s
NEW_POD_NAME="$(kubectl get pods -n volumes-lab \
  -l app=volume-lab-web \
  -o jsonpath='{.items[0].metadata.name}')"
echo "${NEW_POD_NAME}"
```

Read the audit log from the replacement Pod:

```bash
kubectl exec -n volumes-lab "${NEW_POD_NAME}" -c audit-writer -- tail -n 10 /audit/events.log
```

The log should contain entries from both Pod instances.

## Progressive hints

<details>
<summary>Hint 1 — Storage lifecycles</summary>

Use `emptyDir` for generated HTML because it only needs to live for the Pod.

Use a `persistentVolumeClaim` volume for the audit log because it must survive Pod replacement.

</details>

<details>
<summary>Hint 2 — Projected sources</summary>

The projected volume should include `configMap`, `secret`, and `downwardAPI` sources.

</details>

<details>
<summary>Hint 3 — Metadata fields</summary>

Use `metadata.name` and `metadata.namespace`.

</details>

<details>
<summary>Hint 4 — Service routing</summary>

The Deployment Pod label and Service selector must both use:

```text
app: volume-lab-web
```

</details>

<details>
<summary>Hint 5 — Nginx</summary>

Mount the generated site at `/usr/share/nginx/html` and make it read-only.

</details>

## Expected result

- The PVC is `Bound`.
- The init container generates a complete page.
- Nginx serves the page.
- The page contains configuration, Secret data, and Pod metadata.
- The Nginx mount is read-only.
- The audit sidecar writes to persistent storage.
- A replacement Pod sees the old audit log.

## Common errors

### Deployment has zero available replicas

```bash
kubectl describe deployment volume-lab-web -n volumes-lab
kubectl get pods -n volumes-lab
kubectl describe pod <pod-name> -n volumes-lab
```

### Init container fails

```bash
kubectl logs <pod-name> -n volumes-lab -c page-builder
```

Check projected file names and mount paths.

### Nginx serves the default page

The site volume may be mounted at the wrong path, or the init container may have written to a different volume.

### Service has no endpoints

The Service selector does not match the Pod label.

```bash
kubectl get endpoints volume-lab-web -n volumes-lab
kubectl get pods -n volumes-lab --show-labels
```

### PVC remains Pending

```bash
kubectl get storageclass
kubectl describe pvc volume-lab-audit -n volumes-lab
```

## Cleanup

Delete only final challenge resources:

```bash
kubectl delete -f /tmp/09/
```

Or remove the entire lab namespace:

```bash
kubectl delete namespace volumes-lab
```
