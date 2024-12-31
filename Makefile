SHELL := /bin/bash

.PHONY: fmt
fmt:
	stylua -g '*.lua' -- .

.PHONY: lint
lint:
	typos -w

.PHONY: check
check: lint fmt

.PHONY: devc-up
devc-up:
	devcontainer up --workspace-folder=.

.PHONY: devc-up-new
devc-up-new:
	devcontainer up --workspace-folder=. --remove-existing-container

.PHONY: devc-exec
devc-exec:
	devcontainer exec --workspace-folder=. bash

OUTDIR = ~/.local/share/$${NVIM_APPNAME:-nvim}/nvim-dap-cpp.nvim
.PHONY: setup
setup:
	rm -rf $(OUTDIR)
	mkdir -p $(OUTDIR)
	curl -s https://api.github.com/repos/vadimcn/codelldb/releases/latest | jq -r '.assets[].browser_download_url | select(contains("linux-x64"))' | xargs -I {} curl -L {} -o $(OUTDIR)/codelldb.vsix
	unzip -o -d $(OUTDIR) $(OUTDIR)/codelldb.vsix
