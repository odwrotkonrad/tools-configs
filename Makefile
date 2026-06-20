#[what] Project's Makefile
WRAPPERS := run-sync-quick run-sync-full run-repo-build-vm-all
COMMANDS := run-repo-tests run-repo-typecheck run-host-upsert-configs run-host-render-templates run-repo-render-templates run-repo-upsert-git-hooks run-host-restart-services run-host-delete-broken-links run-host-install-all run-host-mk-dirs run-repo-build-vm-base run-repo-build-vm run-repo-ssh-vm run-repo-test-vm
SCRIPTS := root-ln/usr/local/scripts
CI_SCRIPTS := ./ci/zsh/scripts
ZSH := FPATH=$(CURDIR)/ci/zsh/functions:$$FPATH PATH=$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$$PATH zsh -c 'autoload -Uz $(CURDIR)/ci/zsh/functions/*(:t); "$$@"'
PRETTY := $(ZSH) with-sections with-sections
VM_REPO := /Users/ko/projects/configs
IN_VM := ./ci/local/vm/ssh-vm.zsh cd $(VM_REPO) '&&' make
MYPY := mypy --config-file root-ln/Users/ko/.config/mypy/config

export FPATH := $(CURDIR)/ci/zsh/functions:$(FPATH)
export PATH := $(CURDIR)/ci/python/scripts:$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$(PATH)
export PYTHONPATH := $(CURDIR)/$(SCRIPTS)/python
export MYPYPATH := $(CURDIR)/$(SCRIPTS)/python
export GOMPLATE_CONFIG := $(CURDIR)/root-ln/etc/gomplate/gomplate.yaml
.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] wrappers
run-sync-quick: run-host-upsert-configs run-host-delete-broken-links run-repo-upsert-git-hooks run-repo-render-templates
run-sync-full: run-sync-quick run-host-mk-dirs run-host-render-templates
run-repo-build-vm-all: run-repo-build-vm-base run-repo-build-vm
##[<] wrappers

##[>] commands
run-host-upsert-configs:
	@sudo $(PRETTY) s-rt-upsert-configs

run-host-delete-broken-links:
	@sudo $(PRETTY) s-rt-delete-broken-links

run-host-mk-dirs:
	@sudo $(PRETTY) s-rt-mk-dirs

run-host-render-templates:
	@$(PRETTY) $(CI_SCRIPTS)/s-rt-render-templates-host

RENDER_LOCAL ?= --local
run-repo-render-templates:
	@$(PRETTY) $(CI_SCRIPTS)/s-rt-render-templates-repo $(RENDER_LOCAL) $(CURDIR)

run-repo-tests:
	@$(PRETTY) pytest tests/scripts/python

run-repo-typecheck:
	@$(PRETTY) $(MYPY) --scripts-are-modules $(SCRIPTS)/python/s-rt-*
	@$(PRETTY) $(MYPY) $(SCRIPTS)/python/s_rt_scripts_lib

run-repo-upsert-git-hooks:
	@$(PRETTY) lefthook install --force

run-host-install-all:
	@$(PRETTY) $(CI_SCRIPTS)/installs/s-rt-install-all

#[what] reload running service launchagents
run-host-restart-services:
	@$(PRETTY) $(CI_SCRIPTS)/s-rt-restart-services

##[>] vm
run-repo-build-vm-base:
	@$(PRETTY) ./ci/local/vm/build-vm.zsh ko-macos-tahoe-vanilla

run-repo-build-vm:
	@$(PRETTY) ./ci/local/vm/build-vm.zsh ko-macos-tahoe-vanilla-configs-local

run-repo-ssh-vm:
	@./ci/local/vm/ssh-vm.zsh

run-repo-test-vm: run-repo-build-vm
	@$(IN_VM) run-host-upsert-configs
	@$(IN_VM) run-host-mk-dirs
	@$(IN_VM) run-host-install-all
##[<] vm

##[<] commands
