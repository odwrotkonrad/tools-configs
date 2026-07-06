#[what] Project's Makefile
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
WRAPPERS := run-sync run-sync-full run-repo-ci-virt-macos-build-all
COMMANDS := run-host-upsert-configs run-host-render-templates run-repo-ci-render-templates run-repo-ci-prepare-hooks run-repo-ci-precommit-all run-host-restart-services run-host-delete-broken-links run-host-run-scripts-all run-host-run-scripts run-host-mk-dirs run-repo-ci-install-deps run-repo-ci-virt-macos-build-base run-repo-ci-virt-macos-build run-repo-ci-virt-macos-test run-repo-ci-virt-macos-ssh run-repo-ci-virt-linux-build run-repo-ci-virt-linux-test run-repo-ci-virt-linux-ssh

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
run-repo-ci-virt-macos-build-all: run-repo-ci-virt-macos-build-base run-repo-ci-virt-macos-build
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
	@che render-templates --host

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
#[what] render *.repo.tpl onto repo
run-repo-ci-render-templates: | run-repo-ci-install-deps
	@che render-templates --repo

#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
run-repo-ci-precommit-all: | run-repo-ci-install-deps run-repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force

run-repo-ci-install-deps:
	@00-ci-deps.zsh $@

###[>] Virt
#[what] build vanilla base macos image
run-repo-ci-virt-macos-build-base:
	@vm-build.zsh macos-tahoe-vanilla-base

#[what] build configs-local macos image
run-repo-ci-virt-macos-build:
	@vm-build.zsh macos-tahoe-vanilla-configs

#[what] build the macos image then run the che ops in it (cli/macos profile)
run-repo-ci-virt-macos-test: run-repo-ci-virt-macos-build
	@virt-ssh-mac.zsh -c 'CI=1 MK_DRY_RUN_RENDER_SECRETS=true CHE_FORCE_PROFILE=cli/macos make run-sync-full'

#[what] ssh into the macos image (auto-starts if stopped)
run-repo-ci-virt-macos-ssh:
	@virt-ssh-mac.zsh

#[what] build the ci-linux image
run-repo-ci-virt-linux-build:
	@virt-build-linux.zsh

#[what] build the ci-linux image then run the che ops in it (cli/linux profile)
run-repo-ci-virt-linux-test: run-repo-ci-virt-linux-build
	@virt-ssh-linux.zsh -c 'CI=1 MK_DRY_RUN_RENDER_SECRETS=true CHE_FORCE_PROFILE=cli/linux make run-sync-full'

#[what] build the ci-linux image and open an interactive shell in it
run-repo-ci-virt-linux-ssh: run-repo-ci-virt-linux-build
	@virt-ssh-linux.zsh

###[<] Virt
##[<] Onto Repo
