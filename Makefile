#[what] Project's Makefile
#[why] SHELL is a zsh wrapper (not bare `zsh`) to power MK_DRY_RUN: it prints or omits each target's recipe instead of running it
SHELL := $(CURDIR)/ci/zsh/scripts/make-run-target.zsh
.SHELLFLAGS := -c
CHE := che $(if $(CHE_PROFILE),--profiles=$(CHE_PROFILE) --skip-run-if)
WRAPPERS := sync sync-full
COMMANDS := che-install generic-setup host-load-configs host-load-configs-install host-index-workspace host-run-install-scripts host-run-scripts repo-ci-install-deps

.PHONY: $(WRAPPERS) $(COMMANDS)

#[why] this repo's SHELL wrapper glob-expands each recipe word and rejects `${CHE_BIN:-che}`: name che plainly
GENERIC_CHE := che
GENERIC_CHE := che
GENERIC_FILES_UNTRACKED_PROFILES := generic/filesUntracked,repo/filesUntracked
-include shared/generic/make/generic.mk

#[why] this repo installs its own toolchain first: the generic recipes assume che is already runnable
generic-files-tracked-generate generic-files-untracked-generate generic-files-tracked-verify generic-env-generate generic-setup: | repo-ci-install-deps

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
#[why] repo renders run first: the host profiles read prose payloads that ontoRepo generates and
#   .gitignore keeps out of the tree (ai-agents docs, claude rules and snippets), so loading the
#   host before rendering finds nothing to load
#[why] the workspace index inlines each repo's rendered purpose doc, which the host load
#   produces and .gitignore keeps out of the tree: indexing before that load reads nothing
#[what] convenience sync: configs, dirs, hooks, all template renders (repo + host), workspace indexes
sync: generic-files-untracked-generate generic-files-tracked-generate host-load-configs host-index-workspace generic-precommit-install
#[what] full sync: full che op sequence per profile (scripts included), hooks, repo renders
sync-full: generic-files-untracked-generate generic-files-tracked-generate host-load-configs-install generic-precommit-install
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

##[>] Setup [genai-include]
#[what] install the latest released che into ~/.local/bin, only when the one on PATH is older
che-install:
	@curl -fsSL https://konradodwrot.gitlab.io/go-modules/che-install.sh | sh -s -- --skip-if-present-is-newer

#[what] render the generic consumer payload (generic.mk, lefthook.yml, shared/generic/) at the pinned CENTRALIZED_ASSETS_GENERIC_REF
generic-setup:
	@che render-templates --profiles=genericSetup

shared/generic/make/generic.mk: generic-setup

repo-ci-install-deps:
	@00-ci-deps.zsh $@
##[<] Setup
