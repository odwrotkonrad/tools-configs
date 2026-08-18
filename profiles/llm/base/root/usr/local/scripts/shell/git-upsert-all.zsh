#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Full git flow detached: commit, branch-name, MR/PR in order.
#   Each step is a self-contained wrapper logging to its own file.
#   commit-upsert branches off main itself (commit-first, name from the
#   commit); the branch-name step is skipped when it already switched branch.
#   No-op guard: clean tree, on main, main == origin/main => log
#   `no changes`, exit 24 before any step runs.
#   commit-upsert exit 24 (nothing to commit) is not a stop: branch-name and
#   mr-upsert still run, so a clean tree off main or unsynced still ships.
#   Exit 24 only when every step was a no-op.
#   Usage: git-upsert-all [amend]
#   Downstream: git-branch-name-upsert, git-commit-upsert, git-mr-upsert.
#   Exit Codes: 22 sync conflicts · 24 skipped (nothing to do)
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e

autoload -Uz fn-exit-with

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
      -z $(git rev-list origin/main..main 2>/dev/null) ]] fn-exit-with 24 "no changes"

prev_branch=$(git rev-parse --abbrev-ref HEAD)
git-commit-upsert.zsh "$@" && commit_rc=0 || commit_rc=$?
(( commit_rc == 22 )) && exit 22
(( commit_rc == 0 || commit_rc == 24 )) || exit $commit_rc

branch_switched=0
if [[ $(git rev-parse --abbrev-ref HEAD) == $prev_branch ]] {
  git-branch-name-upsert.zsh
  [[ $(git rev-parse --abbrev-ref HEAD) == $prev_branch ]] || branch_switched=1
} else {
  branch_switched=1
}

git-mr-upsert.zsh && mr_rc=0 || mr_rc=$?
(( mr_rc == 22 )) && exit 22
(( mr_rc == 0 || mr_rc == 24 )) || exit $mr_rc

if (( commit_rc == 24 && mr_rc == 24 && ! branch_switched )) fn-exit-with 24 "nothing to do"
print -r -- "done"
##[<] 🤖🤖
