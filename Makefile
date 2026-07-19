#[what] Project's Makefile
#[why] SHELL is a zsh wrapper (not bare `zsh`) to power MK_DRY_RUN: it prints or omits each target's recipe instead of running it
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
CHE := che $(if $(CHE_PROFILE),--profiles=$(CHE_PROFILE) --skip-run-if)
WRAPPERS := sync sync-install repo-ci-virt-macos-build-all
COMMANDS := host-load-configs host-load-configs-install repo-render-templates repo-ci-prepare-hooks repo-ci-run-precommit-all host-run-install-scripts host-run-scripts repo-ci-install-deps repo-ci-virt-macos-build-base repo-ci-virt-macos-build repo-ci-virt-macos-test repo-ci-virt-macos-ssh repo-ci-virt-linux-build repo-ci-virt-linux-test repo-ci-virt-linux-ssh

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] `$ che` - print targets instead of load, if not `$ che` - omit cmd with message
#[vals] delta|all
export MK_DRY_RUN
#[what] render: skip templates with op:// secret refs (no vault fetch), leave dests untouched
#[vals] true|false
export MK_DRY_RUN_RENDER_SECRETS
#[what] force one che profile for host ops, passed as `$ che --profiles --skip-run-if`
#[vals] desktop/macos|cli/macos|cli/linux
export CHE_PROFILE
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] convenience sync: configs, dirs, hooks, all template renders (repo + host)
sync: host-load-configs repo-ci-prepare-hooks repo-render-templates
#[what] full sync: full che op sequence per profile (scripts included), hooks, repo renders
sync-install: host-load-configs-install repo-ci-prepare-hooks repo-render-templates
repo-ci-virt-macos-build-all: repo-ci-virt-macos-build-base repo-ci-virt-macos-build
##[<] Wrappers

##[>] Onto Host [genai-include]
#[what] load configs onto host, profile by profile: each profile's full op sequence minus scripts
host-load-configs: | repo-ci-install-deps
	@$(CHE) run --skip-ops=run-scripts

#[what] install configs onto host, profile by profile: each profile's full op sequence, scripts included
host-load-configs-install: | repo-ci-install-deps
	@$(CHE) run

#[what] run all of the detected profile's scripts
host-run-install-scripts: | repo-ci-install-deps
	@$(CHE) run-scripts

#[what] run profile scripts whose path matches NAME (substring)
host-run-scripts: | repo-ci-install-deps
	@$(CHE) run-scripts $(NAME)
##[<] Onto Host

##[>] Onto Repo (CI) [genai-include]
#[what] render *.ontoRepo.tpl onto repo
repo-render-templates: | repo-ci-install-deps
	@che render-templates --profiles=ontoRepo

#[what] install lefthook git hooks
repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
repo-ci-run-precommit-all: | repo-ci-install-deps repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force

repo-ci-install-deps:
	@00-ci-deps.zsh $@

###[>] Virt
#[what] build vanilla base macos image
repo-ci-virt-macos-build-base:
	@vm-build.zsh macos-tahoe-vanilla-base

#[what] build configs-local macos image
repo-ci-virt-macos-build:
	@vm-build.zsh macos-tahoe-vanilla-configs

#[what] build the macos image then run the che ops in it (cli/macos profile)
repo-ci-virt-macos-test: repo-ci-virt-macos-build
	@virt-ssh-mac.zsh -c 'CI=1 MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/macos make sync-install'

#[what] ssh into the macos image (auto-starts if stopped)
repo-ci-virt-macos-ssh:
	@virt-ssh-mac.zsh

#[what] build the ci-linux image
repo-ci-virt-linux-build:
	@virt-build-linux.zsh

#[what] build the ci-linux image then run the che ops in it (cli/linux profile)
repo-ci-virt-linux-test: repo-ci-virt-linux-build
	@virt-ssh-linux.zsh -c 'CI=1 MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/linux make sync-install'

#[what] build the ci-linux image and open an interactive shell in it
repo-ci-virt-linux-ssh: repo-ci-virt-linux-build
	@virt-ssh-linux.zsh

###[<] Virt
##[<] Onto Repo
