.DEFAULT_GOAL := help

.PHONY: help
help: ## Print the help message
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST) | \
		sort | \
		column -s ':' -t

.PHONY: clean
clean: ## Remove temp resources
	@rm -rf venv vectors metadata *.egg-info \
		`find . -type d -name __pycache__` \
		`find . -type f -name '*.pyc'` \
		.cache .coverage htmlcov

.PHONY: generate
generate: init ## Generate Uptane test vectors
	@. venv/bin/activate && \
		./generator.py -o vectors --ecu-identifier 123 --hardware-id abc

.PHONY: init
init: venv ## Initialize the environment
	. venv/bin/activate && \
		pip install -e . && \
		pip install -Ur requirements.txt && \
		mkdir -p vectors

.PHONY: init-dev
init-dev: venv ## Initialize the dev environment
	. venv/bin/activate && \
		pip install -Ur requirements-dev.txt

TEST ?= 'tests/'
.PHONY: test
test: init-dev ## Run the test suite
	venv/bin/pytest -v

venv: ## Create the virtualenv
	@if [ ! -d venv ]; then python3 -m venv venv; fi


.PHONY: lint
lint: init-dev ## Lint the python files
	@python3 -m flake8
