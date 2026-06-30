#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Full git flow detached: branch-name, commit, MR/PR in order.
#   Each step is a self-contained wrapper logging to its own file.
#   Usage: git-upsert-all [amend]
#   Downstream: git-branch-name-upsert, git-commit-upsert, git-mr-upsert.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e

log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/git-wrappers
mkdir -p $log_dir
exec >>$log_dir/${0:t:r}.log 2>&1
print -r -- "=== ${0:t} $(date +%FT%T) ==="

git-branch-name-upsert.zsh
git-commit-upsert.zsh "$@"
git-mr-upsert.zsh
print -r -- "done"
##[<] 🤖🤖
