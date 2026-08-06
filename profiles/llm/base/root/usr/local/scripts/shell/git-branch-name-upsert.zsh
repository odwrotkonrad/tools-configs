#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync onto main, then create/rename the branch to an llm-suggested name.
#   on main: checkout -b <name>. on a branch: branch -m <name>.
#   merged (sync exit 23): leaves you on main, exits 0 (nothing to name).
#   No-op guard: clean tree, on main, main == origin/main => log
#   `no new commits`, exit 0 before syncing.
#   Usage: git-branch-name-upsert
#   Downstream: git-sync-onto-main, llm-git-branch-name-suggest, git.
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

if [[ -z $(git status --porcelain) &&
      $(git rev-parse --abbrev-ref HEAD) == main &&
      -z $(git rev-list origin/main..main 2>/dev/null) ]] {
  print -r -- "no new commits"
  exit 0
}

git-sync-onto-main.zsh && sync=0 || sync=$?
(( sync == 22 )) && exit 22
(( sync == 23 )) && { print -r -- "merged onto main, nothing to name"; exit 0 }

name=$(llm-git-branch-name-suggest.zsh | jq -r .name)
print -r -- "suggested name: $name"

if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] {
  git checkout -b $name
} else {
  git branch -m $name
}
##[<] 🤖🤖
