#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync onto main, stage all, commit with llm message.
#   on main: commit there first, branch off (name derived from the commit),
#   then reset local main to origin/main so main stays clean.
#   amend arg: git commit --amend, message from HEAD~1..staged diff. Never amend on main.
#   nothing staged after add: exit 24, warns with ⚠️ when the stash is non-empty.
#   hook fails leaving an unstaged diff (docsgen regen): restage, retry once.
#   repo has lefthook.yml but no installed pre-commit hook: install via
#   make repo-ci-prepare-hooks, fallback lefthook install.
#   Usage: git-commit-upsert [amend]
#   Downstream: git-sync-onto-main, git-branch-name-upsert, llm-git-commit-suggest, git.
#   Exit Codes: 22 sync conflicts · 24 skipped (nothing to commit)
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

mode=${1:-}

git-sync-onto-main.zsh && rc=0 || rc=$?
(( rc == 22 )) && exit 22

on_main=0
if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] on_main=1

typeset -a commit_args diff_base
if [[ $mode == amend ]] {
  if (( on_main )) { print -r -- "on main, refusing to amend"; exit 1 }
  print -r -- "amend: amending HEAD"
  commit_args=(--amend)
  diff_base=(HEAD~1)
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

if [[ $mode != amend ]] && { git diff --cached --quiet } {
  print -r -- "nothing to commit, skipping"
  typeset -a stash_entries=(${(f)"$(git stash list)"})
  if (( $#stash_entries )) {
    print -rl -- "  $^stash_entries"
    fn-exit-with 24 "⚠️ stash: $#stash_entries entries"
  }
  fn-exit-with 24
}

out=$(llm-git-commit-suggest.zsh $diff_base)
subject=$(jq -r .subject <<< $out)
description=$(jq -r .description <<< $out)
print -r -- "subject: $subject"

if ! { git commit $commit_args -m $subject -m $description } {
  if { git diff --quiet } { exit 1 }
  print -r -- "hooks regenerated files, restaging and retrying once"
  git add .
  git commit $commit_args -m $subject -m $description
}

if (( on_main )) {
  print -r -- "committed on main, moving commit onto a branch"
  GIT_WRAPPER_COMMITTED=1 git-branch-name-upsert.zsh
}
##[<] 🤖🤖
