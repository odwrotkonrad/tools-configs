#[what] Project's Makefile
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
WRAPPERS := run-sync run-sync-full run-repo-ci-vm-all
COMMANDS := run-host-upsert-configs run-host-render-templates run-repo-ci-render-templates run-repo-ci-prepare-hooks run-repo-ci-precommit-all run-host-restart-services run-host-delete-broken-links run-host-run-scripts-all run-host-run-scripts run-host-mk-dirs run-repo-ci-install-deps run-repo-ci-vm-build-base run-repo-ci-vm-build run-repo-ci-vm-ssh run-repo-ci-vm-test
IN_VM := $(CURDIR)/ci/zsh/scripts/run-in-vm.zsh -c

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] `$ che` - print targets instead of load, if not `$ che` - omit cmd with message
#[vals] delta|all
export MK_DRY_RUN
#[what] render: skip templates with op:// secret refs (no vault fetch), leave dests untouched
#[vals] true|false
export MK_DRY_RUN_RENDER_SECRETS
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] convenience sync: configs, dirs, hooks, all template renders (repo + host)
run-sync: run-host-delete-broken-links run-host-upsert-configs run-host-mk-dirs run-repo-ci-prepare-hooks run-repo-ci-render-templates run-host-render-templates
#[what] full sync: run-sync then run all profile scripts (installs)
run-sync-full: run-sync run-host-run-scripts-all
run-repo-ci-vm-all: run-repo-ci-vm-build-base run-repo-ci-vm-build
##[<] Wrappers

##[>] Onto Host [genai-include]
#[what] load configs onto host (profile-selected symlink + copy ops)
run-host-upsert-configs: | run-repo-ci-install-deps
	@che link
	@che copy

#[what] prune broken symlinks
run-host-delete-broken-links: | run-repo-ci-install-deps
	@che prune-links

#[what] required by configuration and tools dirs
run-host-mk-dirs: | run-repo-ci-install-deps
	@che mk-dirs

#[what] render *.host.tpl onto host
run-host-render-templates: | run-repo-ci-install-deps
	@che render-templates

#[what] run all of the detected profile's scripts
run-host-run-scripts-all: | run-repo-ci-install-deps
	@che run-scripts

#[what] run profile scripts whose path matches NAME (substring)
run-host-run-scripts: | run-repo-ci-install-deps
	@che run-scripts $(NAME)

#[what] reload running service launchagents
run-host-restart-services: | run-repo-ci-install-deps
	@che services bootout
	@che services bootin
	@che services ensure
##[<] Onto Host

##[>] Onto Repo (CI) [genai-include]
RENDER_LOCAL ?= --local
#[what] render *.repo.tpl onto repo
run-repo-ci-render-templates: | run-repo-ci-install-deps
	@tpl-gen-onto-repo.zsh $(RENDER_LOCAL) $(CURDIR)

#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
run-repo-ci-precommit-all: | run-repo-ci-install-deps run-repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force

run-repo-ci-install-deps:
	@00-ci-deps.zsh $@

###[>] VM
#[what] build vanilla base vm image
run-repo-ci-vm-build-base:
	@vm-build.zsh macos-tahoe-vanilla-base

#[what] build configs-local vm image
run-repo-ci-vm-build:
	@vm-build.zsh macos-tahoe-vanilla-configs

#[what] ssh into the local vm
run-repo-ci-vm-ssh:
	@run-in-vm.zsh

#[what] build vm then run the che ops in it (cli/macos profile)
run-repo-ci-vm-test: run-repo-ci-vm-build
	@$(IN_VM) 'CI=1 make run-sync-full'

###[<] VM
##[<] Onto Repo
