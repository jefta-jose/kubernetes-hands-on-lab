.PHONY: preflight validate state clean

preflight:
	bash scripts/preflight.sh

validate:
	python3 scripts/validate_project.py

state:
	bash scripts/show-storage-state.sh

clean:
	bash scripts/cleanup-all.sh
