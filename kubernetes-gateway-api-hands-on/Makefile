SHELL := /usr/bin/env bash
PROVIDER ?= kind
EX ?=
GATEWAY_NAMESPACE ?= gateway-lab
GATEWAY_NAME ?= lab-gateway
PORTS ?= 8080:80
PORT ?= 8080

.PHONY: prereqs setup status apply-solution validate forward stop-forward reset cleanup destroy

prereqs:
	./scripts/check-prereqs.sh $(PROVIDER)

setup:
	./scripts/setup.sh $(PROVIDER)

status:
	./scripts/status.sh

apply-solution:
	@test -n "$(EX)" || (echo "Usage: make apply-solution EX=02-basic-httproute" && exit 1)
	kubectl apply -f exercises/$(EX)/solution/

validate:
	@test -n "$(EX)" || (echo "Usage: make validate EX=02-basic-httproute" && exit 1)
	./exercises/$(EX)/validate.sh

forward:
	./scripts/forward-gateway.sh $(GATEWAY_NAMESPACE) $(GATEWAY_NAME) $(PORTS)

stop-forward:
	./scripts/stop-forward.sh $(PORT)

reset:
	./scripts/reset.sh

cleanup:
	./scripts/cleanup.sh resources

# Deletes the cluster selected with PROVIDER=kind or PROVIDER=minikube.
destroy:
	./scripts/cleanup.sh cluster $(PROVIDER)
