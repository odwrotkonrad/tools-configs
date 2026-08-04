#[what] Project's Makefile
#[why] SHELL is a zsh wrapper (not bare `zsh`) to power MK_DRY_RUN: it prints or omits each target's recipe instead of running it
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
CHE := che $(if $(CHE_PROFILE),--profiles=$(CHE_PROFILE) --skip-run-if)
WRAPPERS := sync sync-install
COMMANDS := host-load-configs host-load-configs-install repo-render-templates repo-ci-prepare-hooks repo-ci-run-precommit-all host-run-install-scripts host-run-scripts repo-ci-install-deps

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] `$ che` - print targets instead of load, if not `$ che` - omit cmd with message
#[vals] delta|all
export MK_DRY_RUN
#[what] render: skip templates with op:// secret refs (no vault fetch), leave dests untouched
#[vals] true|false
export MK_DRY_RUN_RENDER_SECRETS
#[what] force one che profile for host ops, passed as `$ che --profiles --skip-run-if`
#[vals] desktop/macos|cli/macos|virt/linux
export CHE_PROFILE
##[>] 🤖🤖
#[what] che spec validation mode, error aborts on che.yml schema violations
#[vals] warn|error
CHE_VALIDATE_SPEC ?= error
export CHE_VALIDATE_SPEC
##[<] 🤖🤖
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] convenience sync: configs, dirs, hooks, all template renders (repo + host)
sync: host-load-configs repo-ci-prepare-hooks repo-render-templates
#[what] full sync: full che op sequence per profile (scripts included), hooks, repo renders
sync-install: host-load-configs-install repo-ci-prepare-hooks repo-render-templates
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

##[<] Onto Repo
