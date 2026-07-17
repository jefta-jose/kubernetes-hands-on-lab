# Kubernetes Ingress Hands-On Lab

A fill-in-the-blank learning project for practising Kubernetes Ingress locally.

The project starts with a single host rule and progresses through host routing, path routing, path precedence, wildcard hosts, default backends, TLS termination, controller annotations, IngressClasses, and a final integrated challenge.

## What You Will Build

You will use one ingress controller as a shared HTTP/HTTPS entry point for several internal `ClusterIP` Services:

```text
Client
  |
  v
Ingress controller / reverse proxy
  |
  +--> frontend Service --> frontend Pods
  +--> quote Service    --> quote Pods
  +--> quiz Service     --> quiz Pods
  +--> session Service  --> session Pods
```

The exercise manifests contain `________` placeholders. Replace only those placeholders. Completed, runnable manifests are provided under each exercise's `solution/` directory.

## Project Structure

```text
kubernetes-ingress-hands-on/
├── README.md
├── Makefile
├── scripts/
│   ├── check-prereqs.sh
│   ├── setup-cluster.sh
│   ├── deploy-apps.sh
│   ├── generate-tls-secret.sh
│   └── cleanup.sh
├── shared/
│   ├── namespace.yaml
│   └── apps.yaml
└── exercises/
    ├── 01-basic-ingress/
    ├── 02-host-based-routing/
    ├── 03-path-based-routing/
    ├── 04-path-types-and-precedence/
    ├── 05-multiple-rules-and-wildcards/
    ├── 06-default-backend/
    ├── 07-tls-termination/
    ├── 08-cookie-session-affinity/
    ├── 09-ingress-class/
    └── 10-final-challenge/
```

## Prerequisites

Install:

- Docker
- Minikube
- `kubectl`
- `curl`
- OpenSSL

The scripts assume a Bash-compatible shell such as Linux, macOS, or WSL.

Check the prerequisites:

```bash
make check
```

## Start the Lab

From the project root:

```bash
make setup
make apps
```

The setup script:

1. Starts Minikube with the Docker driver when necessary.
2. Enables the Minikube ingress add-on.
3. Waits for the ingress controller.
4. Deploys shared demo applications into the `ingress-lab` namespace.

Check the environment:

```bash
kubectl get pods -n ingress-lab
kubectl get services -n ingress-lab
kubectl get ingressclass
```

Save the Minikube IP:

```bash
export INGRESS_IP="$(minikube ip)"
echo "$INGRESS_IP"
```

If ingress traffic is not reachable from your host, run this in a separate terminal:

```bash
minikube tunnel
```

## Recommended Exercise Workflow

For each exercise:

1. Read the exercise `README.md`.
2. Copy the incomplete file to `/tmp`.
3. Replace every `________` placeholder.
4. Apply the completed file.
5. Run the provided tests.
6. Compare your work with the solution.
7. Delete the resource before moving on.

Example:

```bash
cp exercises/01-basic-ingress/exercise/ingress.yaml /tmp/01-ingress.yaml
nano /tmp/01-ingress.yaml
kubectl apply -f /tmp/01-ingress.yaml
```

Check that no blanks remain:

```bash
grep -R "________" /tmp/01-ingress.yaml
```

The command should print nothing.

## Exercise Order

| Exercise | Main concept |
|---|---|
| 01 | Basic Ingress rule |
| 02 | Host-based routing |
| 03 | Path-based routing |
| 04 | `Exact` and `Prefix` path semantics |
| 05 | Multiple rules and wildcard hosts |
| 06 | Default backend |
| 07 | TLS termination with a Secret |
| 08 | Controller annotations and sticky sessions |
| 09 | IngressClass selection |
| 10 | Final integrated challenge |

## Useful Inspection Commands

```bash
kubectl get ingress -n ingress-lab
kubectl describe ingress -n ingress-lab
kubectl get endpointslices -n ingress-lab
kubectl get events -n ingress-lab --sort-by=.lastTimestamp
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## General Troubleshooting Model

Follow the request path instead of changing several components at once:

```text
DNS or curl --resolve
        |
External ingress address
        |
Ingress controller
        |
Ingress rule
        |
Service
        |
EndpointSlice
        |
Pod
```

Useful checks:

```bash
kubectl get ingressclass
kubectl get ingress -n ingress-lab
kubectl describe ingress <name> -n ingress-lab
kubectl get service -n ingress-lab
kubectl get endpointslices -n ingress-lab
kubectl get pods -n ingress-lab -o wide
```

Test a Service from inside the cluster:

```bash
kubectl run curl-test \
  --rm -it \
  --restart=Never \
  --image=curlimages/curl:8.10.1 \
  -n ingress-lab \
  -- curl -s http://frontend
```

## Clean Up

Delete lab resources while keeping Minikube:

```bash
make clean
```

Delete the entire Minikube cluster:

```bash
make delete-cluster
```

## Design Notes

- Every application Service is `ClusterIP`; only the ingress controller is externally reachable.
- Each exercise uses unique hostnames so exercises can be tested independently.
- `curl --resolve` is used instead of changing public DNS.
- TLS exercises use self-signed certificates intended only for local practice.
- Controller annotations are implementation-specific. The session-affinity exercise assumes ingress-nginx.
