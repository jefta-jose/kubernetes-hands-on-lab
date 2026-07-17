# Kubernetes Services — Hands-On Practice Lab

This project teaches Kubernetes Services through fill-in-the-blank exercises.
It progresses from direct Pod networking to stable Services, DNS discovery,
readiness-aware routing, NodePort exposure, headless Services, aliases, and a
final multi-concept challenge.

The incomplete files contain this placeholder:

```text
________
```

Replace each placeholder with the value that makes the manifest or command
correct. Compare your work with the corresponding `solution.yaml` only after
attempting the exercise.

## What you will practise

1. Direct Pod-to-Pod communication
2. Stable access with ClusterIP Services
3. `port`, `targetPort`, and named container ports
4. DNS-based Service discovery
5. Readiness probes and EndpointSlices
6. External access with NodePort
7. Direct Pod discovery with headless Services
8. DNS aliases with ExternalName Services
9. A final challenge combining the major concepts

## Prerequisites

Install:

- Docker
- `kubectl`
- `kind` or another local Kubernetes cluster
- `curl`
- Bash

Check the prerequisites:

```bash
./scripts/check-prereqs.sh
```

## Recommended local cluster

The included kind configuration maps:

- Host port `8080` to NodePort `30080`
- Host port `8081` to NodePort `30081`

Create the cluster:

```bash
./scripts/create-cluster.sh
```

Confirm it is ready:

```bash
kubectl get nodes
kubectl cluster-info
```

If you use Docker Desktop Kubernetes or Minikube, you can still run the
exercises. The NodePort access commands may differ; each relevant exercise
includes alternatives.

## Project layout

```text
kubernetes-services-practice/
├── cluster/
│   └── kind-cluster.yaml
├── exercises/
│   ├── 01-pod-networking/
│   ├── 02-clusterip-service/
│   ├── 03-service-ports/
│   ├── 04-dns-discovery/
│   ├── 05-readiness-endpoints/
│   ├── 06-nodeport/
│   ├── 07-headless-service/
│   ├── 08-externalname-alias/
│   └── 09-final-challenge/
├── scripts/
├── Makefile
└── README.md
```

Every exercise contains:

- `README.md` — concept, task, commands, hints, expected result, and troubleshooting
- `exercise.yaml` — incomplete manifest containing blanks
- `solution.yaml` — completed and runnable manifest
- `test.sh` — automated verification
- `cleanup.sh` — removes the exercise namespace

## Recommended workflow

Enter an exercise:

```bash
cd exercises/01-pod-networking
```

Open the incomplete file:

```bash
cat exercise.yaml
```

Make a working copy:

```bash
cp exercise.yaml my-answer.yaml
```

Replace every `________` placeholder, then check that none remain:

```bash
grep -n '________' my-answer.yaml
```

Validate the manifest locally:

```bash
kubectl apply --dry-run=client -f my-answer.yaml
```

Run it:

```bash
kubectl apply -f my-answer.yaml
```

Test it:

```bash
./test.sh
```

Clean up:

```bash
./cleanup.sh
```

## Validate all completed solutions

This checks that solution files contain no blanks and asks `kubectl` to parse
them without creating resources:

```bash
./scripts/validate-solutions.sh
```

## Apply all completed solutions

Namespaces isolate the exercises, so all completed solutions can coexist:

```bash
./scripts/apply-all-solutions.sh
```

Then run all tests:

```bash
./scripts/test-all-solutions.sh
```

Remove every exercise namespace:

```bash
./scripts/cleanup-all.sh
```

Delete the kind cluster:

```bash
./scripts/delete-cluster.sh
```

## Useful troubleshooting commands

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get endpointslices -A
kubectl describe pod POD_NAME -n NAMESPACE
kubectl describe svc SERVICE_NAME -n NAMESPACE
kubectl logs POD_NAME -n NAMESPACE
kubectl get events -n NAMESPACE --sort-by=.lastTimestamp
kubectl explain service.spec
```

## Important mental model

A Service is not a long-running proxy Pod. It is a stable networking
abstraction. A selector identifies workloads, EndpointSlices track the current
backend addresses, cluster DNS provides discoverable names, and the cluster's
networking implementation forwards traffic to ready endpoints.

Pods may come and go. The Service contract remains stable.

