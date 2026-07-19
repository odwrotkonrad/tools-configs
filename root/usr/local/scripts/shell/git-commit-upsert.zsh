#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync onto main, branch off if on main, stage all, commit with llm message.
#   amend arg: soft-reset HEAD~1 first (never on main), then re-commit.
#   nothing staged after add: exit 0 (upsert-all continues to mr-upsert).
#   Guard: never commit/amend on main.
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
if (( sync == 23 )) || [[ $(git rev-parse --abbrev-ref HEAD) == main ]] {
  print -r -- "on main, branching off first"
  git-branch-name-upsert.zsh
}

if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] {
  print -r -- "still on main, refusing to commit"
  exit 1
}

if [[ $mode == amend ]] {
  print -r -- "amend: soft-resetting HEAD~1"
  git reset --soft HEAD~1
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

git commit -m $subject -m $description
##[<] 🤖🤖
