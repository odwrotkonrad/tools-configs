#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Full git flow detached: commit, branch-name, MR/PR in order.
#   Each step is a self-contained wrapper logging to its own file.
#   commit-upsert branches off main itself (commit-first, name from the
#   commit); the branch-name step is skipped when it already switched branch.
#   No-op guard: clean tree, on main, main == origin/main => log
#   `no changes`, exit 0 before any step runs.
#   Usage: git-upsert-all [amend]
#   Downstream: git-branch-name-upsert, git-commit-upsert, git-mr-upsert.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e

log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/git-wrappers
mkdir -p $log_dir
##[>] 🤖🤖 foreground run (tty, or child of one): mirror the log to the terminal
if [[ -t 1 || -n $GIT_WRAPPER_FG ]] {
  export GIT_WRAPPER_FG=1
  exec > >(tee -a $log_dir/${0:t:r}.log) 2>&1
} else {
  exec >>$log_dir/${0:t:r}.log 2>&1
}
##[<] 🤖🤖
print -r -- "=== ${0:t} $(date +%FT%T) ==="

if [[ -z $(git status --porcelain) &&
      $(git rev-parse --abbrev-ref HEAD) == main &&
      -z $(git rev-list origin/main..main 2>/dev/null) ]] {
  print -r -- "no changes"
  exit 0
}

pre_branch=$(git rev-parse --abbrev-ref HEAD)
git-commit-upsert.zsh "$@"
if [[ $(git rev-parse --abbrev-ref HEAD) == $pre_branch ]] {
  git-branch-name-upsert.zsh
}
git-mr-upsert.zsh
print -r -- "done"
##[<] 🤖🤖
