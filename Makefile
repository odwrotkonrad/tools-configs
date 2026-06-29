#[what] Project's Makefile
WRAPPERS := run-sync run-sync-full run-repo-ci-vm-all
COMMANDS := run-repo-ci-tests run-repo-ci-typecheck run-host-upsert-configs run-host-render-templates run-repo-ci-render-templates run-repo-ci-prepare-hooks run-host-restart-services run-host-delete-broken-links run-host-install-all run-host-sync-dry-run run-host-mk-dirs run-repo-ci-install-deps run-repo-ci-prepare-executables run-repo-ci-vm-build-base run-repo-ci-vm-build run-repo-ci-vm-ssh run-repo-ci-vm-test
SCRIPTS := root/usr/local/scripts
CI_SCRIPTS := ./ci/zsh/scripts
ZSH := FPATH=$(CURDIR)/ci/zsh/functions:$$FPATH PATH=$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$$PATH zsh -c 'autoload -Uz $(CURDIR)/ci/zsh/functions/*(:t); "$$@"'
PRETTY := $(ZSH) fn-annotate-with-sections fn-annotate-with-sections
VM_REPO := /Users/user/projects/configs
IN_VM := $(CI_SCRIPTS)/vm-ssh.zsh cd $(VM_REPO) '&&' make
MYPY := mypy --config-file root/HOME/.config/mypy/config

export FPATH := $(CURDIR)/ci/zsh/functions:$(FPATH)
export PATH := $(CURDIR)/ci/python/scripts:$(CURDIR)/ci/zsh/scripts:$(CURDIR)/ci/zsh/scripts/installs:$(CURDIR)/ci/go/bin:/usr/local/bin:$(PATH)
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
#[what] load configs onto host (profile-selected symlink + copy passes)
run-host-upsert-configs: | run-repo-ci-prepare-executables
	@$(PRETTY) che link
	@$(PRETTY) che copy

#[what] prune broken symlinks
run-host-delete-broken-links: | run-repo-ci-prepare-executables
	@$(PRETTY) che prune-links

#[what] required by configuration and tools dirs
run-host-mk-dirs: | run-repo-ci-prepare-executables
	@$(PRETTY) che mk-dirs

#[what] render *.host.tpl onto host
run-host-render-templates: | run-repo-ci-prepare-executables
	@$(PRETTY) che render-templates

#[what] run the detected profile's install units
run-host-install-all: | run-repo-ci-prepare-executables
	@$(PRETTY) che install-tools

#[what] preview every sync pass; prints actions, mutates nothing
run-host-sync-dry-run: | run-repo-ci-prepare-executables
	@$(PRETTY) che prune-links --dry-run
	@$(PRETTY) che mk-dirs --dry-run
	@$(PRETTY) che link --dry-run
	@$(PRETTY) che copy --dry-run
	@$(PRETTY) che render-templates --dry-run

#[what] reload running service launchagents
run-host-restart-services: | run-repo-ci-prepare-executables
	@$(PRETTY) che services bootout
	@$(PRETTY) che services bootin
	@$(PRETTY) che services ensure
##[<] Onto Host

##[>] Onto Repo (CI) [genai-include]
RENDER_LOCAL ?= --local
#[what] render *.repo.tpl onto repo
run-repo-ci-render-templates: | run-repo-ci-prepare-executables
	@$(PRETTY) $(CI_SCRIPTS)/tpl-gen-onto-repo.zsh $(RENDER_LOCAL) $(CURDIR)

#[what] test pytest & go
run-repo-ci-tests:
	@$(PRETTY) pytest tests/scripts/python
	@cd ci/go && $(PRETTY) go test ./...

#[what] mypy typecheck
run-repo-ci-typecheck:
	@$(PRETTY) $(MYPY) --scripts-are-modules $(SCRIPTS)/python/*
	@$(PRETTY) $(MYPY) --scripts-are-modules ci/python/scripts/*
	@$(PRETTY) $(MYPY) $(SCRIPTS)/python/root_scripts_lib

#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@$(PRETTY) lefthook install --force

#[what] install build deps (go toolchain from go.dev)
run-repo-ci-install-deps:
	@$(PRETTY) $(CI_SCRIPTS)/installs/10-golang.zsh

#[what] compile ci/go cmds into ci/go/bin
run-repo-ci-prepare-executables: | run-repo-ci-install-deps
	@cd ci/go && $(PRETTY) go build -o bin/ ./packages/...

###[>] VM
#[what] build vanilla base vm image
run-repo-ci-vm-build-base:
	@$(PRETTY) $(CI_SCRIPTS)/vm-build.zsh macos-tahoe-vanilla-base

#[what] build configs-local vm image
run-repo-ci-vm-build:
	@$(PRETTY) $(CI_SCRIPTS)/vm-build.zsh macos-tahoe-vanilla-configs

#[what] ssh into the local vm
run-repo-ci-vm-ssh:
	@$(PRETTY) $(CI_SCRIPTS)/vm-ssh.zsh

#[what] build vm then run the che passes in it (cli/macos profile)
run-repo-ci-vm-test: run-repo-ci-vm-build
	@$(IN_VM) run-host-upsert-configs
	@$(IN_VM) run-host-mk-dirs
	@$(IN_VM) run-host-install-all
	@$(IN_VM) run-host-render-templates
###[<] VM
##[<] Onto Repo
