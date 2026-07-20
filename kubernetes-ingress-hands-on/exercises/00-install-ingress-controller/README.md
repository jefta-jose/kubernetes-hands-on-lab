# Exercise 00 — Install the Ingress Controller

## 1. Concept

An Ingress object is only a set of routing rules. Kubernetes does not process
those rules by itself. An **ingress controller** must watch the cluster, read
the Ingress objects, and run a reverse proxy that receives HTTP and HTTPS
requests.

This lab uses the NGINX ingress controller supplied by Minikube's `ingress`
add-on. Enabling the add-on creates all of the related Kubernetes resources,
including:

- The `ingress-nginx` namespace, which groups the controller resources.
- The `ingress-nginx-controller` Deployment, which runs the controller Pods.
- The `ingress-nginx-controller` Service, which provides a stable entry point
  in front of those Pods.
- The `nginx` IngressClass, which allows an Ingress to select this controller.
- The required ConfigMaps, ServiceAccounts, roles, and admission resources.

Creating only a namespace and a Service would not be enough. A Service does not
run an application; it only sends traffic to matching Pods. The controller
Deployment supplies those Pods, so this exercise installs the complete add-on.

## 2. Start or Check Minikube

From the `kubernetes-ingress-hands-on` project directory, check whether the
cluster is running:

```bash
minikube status
```

If it is not running, start it with the Docker driver:

```bash
minikube start --driver=docker
```

`minikube` is the default profile name. If you deliberately use another
profile, add `-p PROFILE_NAME` to each `minikube` command in this exercise.

## 3. Inspect the Cluster Before Installation

These commands may report `NotFound` or print no matching resources. That is
expected when the add-on has not been enabled yet:

```bash
kubectl get namespace ingress-nginx
kubectl get deployment,service -n ingress-nginx
kubectl get ingressclass
```

This gives you a before-and-after comparison. `kubectl` talks to the currently
selected Kubernetes cluster; verify it is Minikube with:

```bash
kubectl config current-context
```

The expected context is `minikube` unless you chose another profile name.

## 4. Install ingress-nginx

Enable Minikube's ingress add-on:

```bash
minikube addons enable ingress
```

This command asks Minikube to install and configure ingress-nginx. Minikube—not
the learner—creates the `ingress-nginx` namespace and the controller resources
inside it. This is safer and more reproducible than copying a controller
manifest whose version may not match the installed Minikube version.

Wait until the controller Deployment is available:

```bash
kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Available \
  deployment/ingress-nginx-controller \
  --timeout=240s
```

The pieces of this command mean:

- `--namespace ingress-nginx` looks in the namespace created by the add-on.
- `deployment/ingress-nginx-controller` selects the controller Deployment.
- `--for=condition=Available` waits for it to have an available Pod.
- `--timeout=240s` stops waiting after four minutes instead of hanging forever.

## 5. Verify What Was Created

Check the namespace:

```bash
kubectl get namespace ingress-nginx
```

Check the controller Pods and Deployment:

```bash
kubectl get deployment,pods -n ingress-nginx
```

Check the Service that will receive the lab traffic:

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx
```

Check the IngressClass:

```bash
kubectl get ingressclass nginx
```

The important relationship is:

```text
curl on your host
        |
        | kubectl port-forward
        v
Service/ingress-nginx-controller
        |
        v
ingress-nginx-controller Pod
        |
        | reads an Ingress rule
        v
lab Service and application Pods
```

The exact number and names of supporting resources can vary with the Minikube
version. The namespace, available controller Deployment, controller Service,
and `nginx` IngressClass are the important results for this lab.

## 6. Deploy the Lab Applications

The ingress controller is now installed, but it still needs applications to
route traffic to. Deploy the shared Services and Pods:

```bash
make apps
```

Verify them:

```bash
kubectl get deployments,pods,services -n ingress-lab
```

These application Services are the backends used in Exercises 01–10. They are
separate from `service/ingress-nginx-controller`: the controller Service accepts
traffic, while the application Services are the destinations selected by the
Ingress rules.

## 7. Open the Connection from Your Host

The Docker-driver Minikube node IP may be reachable only inside Docker's
network. Open a local connection to the controller Service instead:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80 8443:443
```

Keep this command running in its own terminal. Here is how to read it:

- `-n ingress-nginx` selects the namespace installed in section 4.
- `service/ingress-nginx-controller` uses the format
  `<resource-type>/<resource-name>` and selects the Service inspected in
  section 5.
- `8080:80` maps HTTP port `8080` on your host to port `80` of the Service.
- `8443:443` maps HTTPS port `8443` on your host to port `443` of the Service.

The left side is always the host port and the right side is the Kubernetes
Service port. The higher host ports avoid requiring administrator privileges
and are less likely to conflict with another web server.

When it is working, the terminal reports:

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from 127.0.0.1:8443 -> 443
```

The port-forward is temporary. Pressing Ctrl+C or closing that terminal stops
it, and curl will then report `Connection refused` until it is started again.

## 8. Expected Result

Before starting Exercise 01, all of these checks should succeed:

```bash
kubectl get namespace ingress-nginx
kubectl get deployment ingress-nginx-controller -n ingress-nginx
kubectl get service ingress-nginx-controller -n ingress-nginx
kubectl get ingressclass nginx
kubectl get services -n ingress-lab
```

Leave the port-forward running, open another terminal, and continue to
Exercise 01.

## 9. Common Errors

### `minikube: command not found`

Install Minikube, then run `make check` to verify the lab prerequisites.

### The current kubectl context is not Minikube

Select the default Minikube context:

```bash
kubectl config use-context minikube
```

Only do this when `minikube status` confirms that the default profile is
running. A custom profile normally has a matching custom context name.

### Timed out waiting for the Deployment

Inspect the Pods and recent events:

```bash
kubectl get pods -n ingress-nginx
kubectl get events -n ingress-nginx --sort-by=.lastTimestamp
minikube addons list
```

### The local port is already in use

Stop the process using `8080` or `8443`, or choose different left-hand ports.
For example:

```bash
kubectl port-forward -n ingress-nginx \
  service/ingress-nginx-controller \
  9080:80 9443:443
```

If you choose different ports, use those same values for
`INGRESS_HTTP_PORT` and `INGRESS_HTTPS_PORT` in later exercises.

## 10. Cleanup

Do not disable the add-on between exercises; Exercises 01–10 need it. After you
finish the entire lab, you can remove it with:

```bash
minikube addons disable ingress
```

Disabling the add-on removes controller resources and will break every Ingress
test until it is enabled again.
