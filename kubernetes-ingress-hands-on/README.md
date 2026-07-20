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

The manifests in Exercises 01–10 contain `________` placeholders. Replace only
those placeholders. Completed, runnable manifests are provided under those
exercises' `solution/` directories. Exercise 00 is command-driven because it
installs the controller that all the manifest exercises depend on.

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
    ├── 00-install-ingress-controller/
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

From the project root, choose one setup approach.

For the guided approach, start Minikube, complete Exercise 00, and deploy the
applications when that exercise instructs you to:

```bash
minikube start --driver=docker
```

Then follow [Exercise 00](exercises/00-install-ingress-controller/README.md).

Alternatively, the automated setup performs the same installation and also
deploys the applications:

```bash
make setup
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

Expose the ingress controller to your host. Keep this command running in a
separate terminal for the duration of the lab:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

Here is how to read that command:

- `kubectl port-forward` creates a temporary connection from ports on your host
  to ports inside the cluster. It runs only while this command remains running.
- `-n ingress-nginx` tells `kubectl` to look in the `ingress-nginx` namespace.
  Minikube creates that namespace when its ingress add-on is enabled.
- `service/ingress-nginx-controller` selects a Kubernetes resource by
  `<resource-type>/<resource-name>`. It means the Service named
  `ingress-nginx-controller`, which is the entry point in front of the NGINX
  ingress-controller Pods. You can inspect it with
  `kubectl get service ingress-nginx-controller -n ingress-nginx`.
- Port mappings use `LOCAL_PORT:CLUSTER_PORT`. Therefore, `8080:80` sends HTTP
  from port `8080` on your host to port `80` of the Service, and `8443:443`
  sends HTTPS from host port `8443` to Service port `443`.

Ports `8080` and `8443` are used on the host because the standard ports `80`
and `443` may already be occupied and often require administrator privileges.

This port-forward is required when the Docker-driver Minikube IP is a
container-only address.
In the terminal where you run the exercises, define the host-reachable endpoint:

```bash
export INGRESS_HOST=127.0.0.1
export INGRESS_HTTP_PORT=8080
export INGRESS_HTTPS_PORT=8443
```

`export` creates shell environment variables so later commands can reuse the
address and ports without repeating them. `127.0.0.1` is the loopback address:
it means "this host", where `kubectl port-forward` is listening.

An HTTP test has this general form:

```bash
curl --resolve HOSTNAME:"$INGRESS_HTTP_PORT":"$INGRESS_HOST" \
  http://HOSTNAME:"$INGRESS_HTTP_PORT"/
```

`--resolve` gives curl a temporary hostname mapping in the form
`hostname:port:address`. It tells curl to connect to `127.0.0.1:8080` without
changing the hostname in the URL. That distinction matters: the network
connection goes through the local port-forward, but NGINX still receives the
exercise hostname in the HTTP `Host` header and can select the correct Ingress
rule. For HTTPS, keeping the hostname also supplies the correct TLS SNI name.
This affects only that curl command; it does not edit DNS or `/etc/hosts`.

`minikube tunnel` is not used by these exercises;
it targets `LoadBalancer` Services, while the Minikube ingress add-on commonly
exposes its controller through a different Service type.

## Recommended Exercise Workflow

For each exercise:

1. Complete Exercise 00 once to install the controller and applications.
2. Read the exercise `README.md`.
3. Copy the incomplete file to `/tmp`.
4. Replace every `________` placeholder.
5. Apply the completed file.
6. Start the ingress-controller port-forward if it is not already running.
7. Run the provided tests.
8. Compare your work with the solution.
9. Delete the resource before moving on.

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
| 00 | Install and verify the NGINX ingress controller |
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
