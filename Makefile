#[what] Project's Makefile
WRAPPERS := run-sync run-sync-full run-repo-ci-vm-all
COMMANDS := run-repo-ci-tests run-repo-ci-typecheck run-host-upsert-configs run-host-render-templates run-repo-ci-render-templates run-repo-ci-prepare-hooks run-host-restart-services run-host-delete-broken-links run-host-install-all run-host-mk-dirs run-repo-ci-prepare-executables run-repo-ci-vm-build-base run-repo-ci-vm-build run-repo-ci-vm-ssh run-repo-ci-vm-test
SCRIPTS := root/usr/local/scripts
CI_SCRIPTS := ./ci/zsh/scripts
ZSH := FPATH=$(CURDIR)/ci/zsh/functions:$$FPATH PATH=$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$$PATH zsh -c 'autoload -Uz $(CURDIR)/ci/zsh/functions/*(:t); "$$@"'
PRETTY := $(ZSH) annotate-with-sections annotate-with-sections
VM_REPO := /Users/user/projects/configs
IN_VM := ./ci/local/vm/ssh-vm.zsh cd $(VM_REPO) '&&' make
MYPY := mypy --config-file root/HOME/.config/mypy/config

export FPATH := $(CURDIR)/ci/zsh/functions:$(FPATH)
export PATH := $(CURDIR)/ci/python/scripts:$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$(CURDIR)/ci/go/bin:$(PATH)
export PYTHONPATH := $(CURDIR)/$(SCRIPTS)/python
export MYPYPATH := $(CURDIR)/$(SCRIPTS)/python
export GOMPLATE_CONFIG := $(CURDIR)/root/etc/gomplate/gomplate.yaml
.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Wrappers [genai-include]
run-sync: run-host-delete-broken-links run-host-upsert-configs run-host-mk-dirs run-repo-ci-prepare-hooks run-repo-ci-render-templates
#[why] run-host-render-templates is not quick
run-sync-full: run-repo-ci-prepare-executables run-sync run-host-render-templates
run-repo-ci-vm-all: run-repo-ci-vm-build-base run-repo-ci-vm-build
##[<] Wrappers

##[>] Onto Host [genai-include]
#[what] load configs onto host
run-host-upsert-configs:
	@sudo $(PRETTY) upsert-configs

#[what] prune broken symlinks
run-host-delete-broken-links:
	@sudo $(PRETTY) delete-broken-links

#[what] required by configuration and tools dirs
run-host-mk-dirs:
	@sudo $(PRETTY) mk-dirs

#[what] render *.host.auto.tmpl onto host
run-host-render-templates:
	@$(PRETTY) $(CI_SCRIPTS)/tmpl-render-onto-host

run-host-install-all:
	@$(PRETTY) $(CI_SCRIPTS)/installs/host-install-all

#[what] reload running service launchagents
run-host-restart-services:
	@$(PRETTY) $(CI_SCRIPTS)/restart-services
##[<] Onto Host

##[>] Onto Repo (CI) [genai-include]
RENDER_LOCAL ?= --local
#[what] render *.repo.auto.tmpl onto repo
run-repo-ci-render-templates: | run-repo-ci-prepare-executables
	@$(PRETTY) $(CI_SCRIPTS)/tmpl-render-onto-repo $(RENDER_LOCAL) $(CURDIR)

#[what] test pytest & go
run-repo-ci-tests:
	@$(PRETTY) pytest tests/scripts/python
	@cd ci/go/src && $(PRETTY) go test ./...

#[what] mypy typecheck
run-repo-ci-typecheck:
	@$(PRETTY) $(MYPY) --scripts-are-modules $(SCRIPTS)/python/s-root-*
	@$(PRETTY) $(MYPY) --scripts-are-modules ci/python/scripts/*
	@$(PRETTY) $(MYPY) $(SCRIPTS)/python/s_root_scripts_lib

#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@$(PRETTY) lefthook install --force

#[what] compile ci/go cmds into ci/go/bin
run-repo-ci-prepare-executables:
	@cd ci/go/src && $(PRETTY) go build -o ../bin/ ./cmd/...

###[>] VM
#[what] build vanilla base vm image
run-repo-ci-vm-build-base:
	@$(PRETTY) $(CI_SCRIPTS)/build-vm configs-macos-tahoe-vanilla

#[what] build configs-local vm image
run-repo-ci-vm-build:
	@$(PRETTY) $(CI_SCRIPTS)/build-vm configs-macos-tahoe-vanilla-configs-local

#[what] ssh into the local vm
run-repo-ci-vm-ssh:
	@./ci/local/vm/ssh-vm.zsh

#[what] build vm then run host upsert in it
run-repo-ci-vm-test: run-repo-ci-vm-build
	@$(IN_VM) run-host-upsert-configs
	@$(IN_VM) run-host-mk-dirs
	@$(IN_VM) run-host-install-all
###[<] VM
##[<] Onto Repo
