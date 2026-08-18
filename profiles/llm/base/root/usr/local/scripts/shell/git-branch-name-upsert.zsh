#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync onto main, then create/rename the branch to an llm-suggested name.
#   on main: checkout -b <name>, then reset local main to origin/main.
#   on a branch: branch -m <name>.
#   merged (sync exit 23): leaves you on main, exits 0 (nothing to name).
#   No-op guard: clean tree, on main, main == origin/main => log
#   `no new commits`, exit 0 before syncing.
#   No commits in range: dirty tree => hand over to git-commit-upsert (commits,
#   then calls back with GIT_WRAPPER_COMMITTED=1), clean tree => exit 24.
#   Usage: git-branch-name-upsert
#   Downstream: git-sync-onto-main, git-commit-upsert, llm-git-branch-name-suggest, git.
#   Exit Codes: 22 sync conflicts · 24 skipped (no commits to name)
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
      -z $(git rev-list origin/main..main 2>/dev/null) ]] {
  print -r -- "no new commits"
  exit 0
}

git-sync-onto-main.zsh && rc=0 || rc=$?
(( rc == 22 )) && exit 22
(( rc == 23 )) && { print -r -- "merged onto main, nothing to name"; exit 0 }

##[>] 🤖🤖
range=$([[ $(git rev-parse --abbrev-ref HEAD) == main ]] && print origin/main..HEAD || print main..HEAD)
if [[ -z $(git log --format=%H $range) ]] {
  if [[ -z $(git status --porcelain) || -n $GIT_WRAPPER_COMMITTED ]] fn-exit-with 24 "no commits to name"
  print -r -- "no commits, committing first"
  exec git-commit-upsert.zsh
}
##[<] 🤖🤖

name=$(llm-git-branch-name-suggest.zsh | jq -r .name)
print -r -- "suggested name: $name"

if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] {
  git checkout -b $name
  git branch -f main origin/main
  print -r -- "main reset to origin/main"
} else {
  git branch -m $name
}
##[<] 🤖🤖
