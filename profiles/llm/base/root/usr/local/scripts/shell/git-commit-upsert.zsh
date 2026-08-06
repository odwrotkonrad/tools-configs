#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync onto main, stage all, commit with llm message.
#   on main: commit there first, branch off (name derived from the commit),
#   then reset local main to origin/main so main stays clean.
#   amend arg: soft-reset HEAD~1 first, then re-commit. Never amend on main.
#   nothing staged after add: exit 0 (upsert-all continues to mr-upsert).
#   hook fails leaving an unstaged diff (docsgen regen): restage, retry once.
#   repo has lefthook.yml but no installed pre-commit hook: install via
#   make repo-ci-prepare-hooks, fallback lefthook install.
#   Usage: git-commit-upsert [amend]
#   Downstream: git-sync-onto-main, git-branch-name-upsert, llm-git-commit-suggest, git.
#   Exit Codes: 22 sync conflicts
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

mode=${1:-}

git-sync-onto-main.zsh && sync=0 || sync=$?
(( sync == 22 )) && exit 22

on_main=0
if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] on_main=1

if [[ $mode == amend ]] {
  if (( on_main )) { print -r -- "on main, refusing to amend"; exit 1 }
  print -r -- "amend: soft-resetting HEAD~1"
  git reset --soft HEAD~1
}

repo_root=$(git rev-parse --show-toplevel)
hook_path=$(git rev-parse --git-path hooks/pre-commit)
if [[ -f $repo_root/lefthook.yml && ! -e $hook_path ]] {
  print -r -- "lefthook.yml present, hooks missing: installing"
  if { make -C $repo_root -n repo-ci-prepare-hooks &>/dev/null } {
    make -C $repo_root repo-ci-prepare-hooks
  } else {
    print -r -- "warning: no repo-ci-prepare-hooks make target, falling back to lefthook install"
    lefthook install
  }
}

git add .

if { git diff --cached --quiet } {
  print -r -- "nothing to commit, skipping"
  exit 0
}

out=$(llm-git-commit-suggest.zsh)
subject=$(jq -r .subject <<< $out)
description=$(jq -r .description <<< $out)
print -r -- "subject: $subject"

if ! { git commit -m $subject -m $description } {
  if { git diff --quiet } { exit 1 }
  print -r -- "hooks regenerated files, restaging and retrying once"
  git add .
  git commit -m $subject -m $description
}

if (( on_main )) {
  print -r -- "committed on main, moving commit onto a branch"
  git-branch-name-upsert.zsh
  git branch -f main origin/main
  print -r -- "main reset to origin/main"
}
##[<] 🤖🤖
