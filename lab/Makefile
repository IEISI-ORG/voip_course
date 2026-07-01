# SOVOC lab control surface. `make help` lists targets.
COMPOSE ?= docker compose
SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: help init up down restart status logs ps segtest clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

init: ## Create .env from template if missing
	@test -f .env || (cp .env.example .env && echo "Created .env — edit secrets before `make up`.")

up: init ## Start the full topology
	$(COMPOSE) up -d

down: ## Stop and remove containers (keeps volumes)
	$(COMPOSE) down

restart: down up ## Recreate the topology

status: ## Show service + network status
	@$(COMPOSE) ps
	@echo "--- networks ---"
	@docker network ls --filter name=sovoc_ --format 'table {{.Name}}\t{{.Driver}}'

logs: ## Tail logs (use S=<service> to scope, e.g. make logs S=edge-sbc)
	$(COMPOSE) logs -f $(S)

ps: status ## Alias for status

segtest: ## M0 segmentation check: redteam MUST NOT reach core/mgmt
	@echo "[segtest] redteam -> core (expect FAIL/unreachable):"
	@-$(COMPOSE) exec -T redteam sh -c 'command -v ping >/dev/null && ping -c1 -W1 172.28.20.21 || echo "no-ping-tool (add in A6)"'
	@echo "[segtest] redteam -> edge-sbc (expect reachable):"
	@-$(COMPOSE) exec -T redteam sh -c 'command -v ping >/dev/null && ping -c1 -W1 172.28.10.10 || echo "no-ping-tool (add in A6)"'

clean: ## Stop and remove containers, networks, and volumes
	$(COMPOSE) down -v --remove-orphans
