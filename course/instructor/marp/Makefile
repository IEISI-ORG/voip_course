# SOVOC E4 — render the instructor MARP decks (../slides/*.md) to HTML/PDF and validate rendering.
# Requires: marp-cli, node + playwright (npm i), xvfb-run. See README.
SLIDES := ../slides
OUT    := out

.PHONY: help html pdf check watch clean deps
.DEFAULT_GOAL := help

help: ## Show targets
	@grep -E '^[a-z]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-8s %s\n",$$1,$$2}'

deps: ## Install the Playwright module + browser (network)
	npm install --no-audit --no-fund playwright
	npx playwright install chromium

html: ## Render all decks to self-contained HTML in out/
	@mkdir -p $(OUT)
	marp --input-dir $(SLIDES) --output $(OUT) --html
	@rm -f $(OUT)/README.html

pdf: ## Render all decks to PDF (needs a chromium for marp)
	@mkdir -p $(OUT)
	marp --input-dir $(SLIDES) --output $(OUT) --pdf --allow-local-files
	@rm -f $(OUT)/README.pdf

check: html ## Render + validate every deck with Playwright under a headless X server
	xvfb-run -a node render-check.js $(OUT)

watch: ## Live-preview while editing (marp server)
	marp --input-dir $(SLIDES) --output $(OUT) --html --watch

clean: ## Remove rendered output
	rm -rf $(OUT)
