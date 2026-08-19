#[what] Project's Makefile
#[why] SHELL is a zsh wrapper (not bare `zsh`) to power MK_DRY_RUN: it prints or omits each target's recipe instead of running it
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
CHE := che $(if $(CHE_PROFILE),--profiles=$(CHE_PROFILE) --skip-run-if)
WRAPPERS := repo-prepare-dev-env sync sync-full
COMMANDS := semver-next tag-mint host-load-configs host-load-configs-install host-index-workspace repo-render-templates repo-ci-prepare-hooks repo-ci-run-precommit-all host-run-install-scripts host-run-scripts repo-ci-install-deps

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
#[why] render precedes hooks: the docsgen pre-commit hook runs the repo render and fails on drift,
#   so a fresh clone whose generated files were never rendered would fail its first commit
#[what] make a fresh clone a working checkout: generated docs, dependencies, git hooks
repo-prepare-dev-env: repo-render-templates repo-ci-install-deps repo-ci-prepare-hooks

#[why] repo renders run first: the host profiles read prose payloads that ontoRepo generates and
#   .gitignore keeps out of the tree (AGENTS.md.ontoHost.tpl, claude snippets), so loading the host
#   before rendering finds nothing to load
#[why] the workspace index inlines each repo's rendered purpose doc, which the host load
#   produces and .gitignore keeps out of the tree: indexing before that load reads nothing
#[what] convenience sync: configs, dirs, hooks, all template renders (repo + host), workspace indexes
sync: repo-render-templates host-load-configs host-index-workspace repo-ci-prepare-hooks
#[what] full sync: full che op sequence per profile (scripts included), hooks, repo renders
sync-full: repo-render-templates host-load-configs-install repo-ci-prepare-hooks
##[<] Wrappers

##[>] Onto Host [genai-include]
#[what] load configs onto host, profile by profile: each profile's full op sequence minus scripts and package installs
host-load-configs: | repo-ci-install-deps
	@$(CHE) run --skip-ops=run-scripts,install-packages

#[what] install configs onto host, profile by profile: each profile's full op sequence, scripts included
host-load-configs-install: | repo-ci-install-deps
	@$(CHE) run

#[what] run all of the detected profile's scripts
host-run-install-scripts: | repo-ci-install-deps
	@$(CHE) run-scripts

#[what] run profile scripts whose path matches NAME (substring)
host-run-scripts: | repo-ci-install-deps
	@$(CHE) run-scripts $(NAME)

#[why] control's index profile carries no auth gate: indexing reads dirs already on disk, so a
#   routine sync refreshes the map with no token in the environment and no network call
#[what] regenerate the workspace repo indexes (parent-dir repo-index.md, AGENTS.md, CLAUDE.md)
host-index-workspace: | repo-ci-install-deps
	@che run-scripts --profiles=indexWorkspace 20-index
##[<] Onto Host

##[>] Release [genai-include]
#[what] print the next semver tag inferred from the last tag..HEAD diff (override: `semver: major|minor|patch` commit token)
semver-next: repo-render-templates
	@ci/semver-bump.zsh

#[what] mint and push the next semver tag (CI: authed via TAG_TOKEN)
tag-mint: repo-render-templates
	@ci/tag-mint.zsh
##[<] Release

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
