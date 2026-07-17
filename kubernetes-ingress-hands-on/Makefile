SHELL := /usr/bin/env bash

.PHONY: check setup apps status clean delete-cluster

check:
	./scripts/check-prereqs.sh

setup:
	./scripts/setup-cluster.sh

apps:
	./scripts/deploy-apps.sh

status:
	kubectl get all,ingress -n ingress-lab
	kubectl get ingressclass

clean:
	./scripts/cleanup.sh

delete-cluster:
	./scripts/cleanup.sh --delete-cluster
