#[what] Project's Makefile
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
WRAPPERS := run-sync run-sync-full run-repo-ci-vm-all
COMMANDS := run-repo-ci-tests-go run-host-upsert-configs run-host-render-templates run-repo-ci-render-templates run-repo-ci-prepare-hooks run-host-restart-services run-host-delete-broken-links run-host-install-all run-host-mk-dirs run-repo-ci-install-deps run-repo-ci-prepare-executables run-repo-ci-vm-build-base run-repo-ci-vm-build run-repo-ci-vm-ssh run-repo-ci-vm-test
IN_VM := $(CURDIR)/ci/zsh/scripts/run-in-vm.zsh -c

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] `$ che` - print targets instead of load, if not `$ che` - omit cmd with message
#[vals] delta|all
export MK_DRY_RUN
##[<] Environment Variables

##[>] Wrappers [genai-include]
run-sync: run-host-delete-broken-links run-host-upsert-configs run-host-mk-dirs run-repo-ci-prepare-hooks run-repo-ci-render-templates
#[why] run-host-render-templates is not quick
run-sync-full: run-repo-ci-prepare-executables run-sync run-host-render-templates
run-repo-ci-vm-all: run-repo-ci-vm-build-base run-repo-ci-vm-build
##[<] Wrappers

##[>] Onto Host [genai-include]
#[what] load configs onto host (profile-selected symlink + copy ops)
run-host-upsert-configs: | run-repo-ci-prepare-executables
	@che link
	@che copy

#[what] prune broken symlinks
run-host-delete-broken-links: | run-repo-ci-prepare-executables
	@che prune-links

#[what] required by configuration and tools dirs
run-host-mk-dirs: | run-repo-ci-prepare-executables
	@che mk-dirs

#[what] render *.host.tpl onto host
run-host-render-templates: | run-repo-ci-prepare-executables
	@che render-templates

#[what] run the detected profile's install units
run-host-install-all: | run-repo-ci-prepare-executables
	@che install-tools

#[what] reload running service launchagents
run-host-restart-services: | run-repo-ci-prepare-executables
	@che services bootout
	@che services bootin
	@che services ensure
##[<] Onto Host

##[>] Onto Repo (CI) [genai-include]
RENDER_LOCAL ?= --local
#[what] render *.repo.tpl onto repo
run-repo-ci-render-templates: | run-repo-ci-prepare-executables
	@tpl-gen-onto-repo.zsh $(RENDER_LOCAL) $(CURDIR)

#[what] test go
run-repo-ci-tests-go: | run-repo-ci-install-deps
	@go test -C ci/go ./...

#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@lefthook install --force

run-repo-ci-install-deps:
	@00-ci-deps.zsh $@

#[what] compile ci/go cmds into ci/go/bin
run-repo-ci-prepare-executables: | run-repo-ci-install-deps
	@go build -C ci/go -o bin/ ./packages/... $@

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
	@$(IN_VM) 'make run-sync-full'

###[<] VM
##[<] Onto Repo
