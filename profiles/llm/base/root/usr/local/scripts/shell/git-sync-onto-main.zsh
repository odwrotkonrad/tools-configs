#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Sync working branch with main. Autostash dirty tree.
#   on main: fast-forward from origin, exit 0.
#   on a branch:
#     1. fast-forward local main from origin
#     2. up to date (branch contains main): exit 0
#     3. merged into main: checkout main, exit 23
#     4. else rebase branch onto main
#   on conflict: print conflicted files, leave the rebase in progress, exit 22.
#   Usage: git-sync-onto-main
#   Downstream: git, origin.
#   Exit Codes: 22 rebase conflicts · 23 already merged (switched to main)
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e

autoload -Uz fn-exit-with

branch=$(git rev-parse --abbrev-ref HEAD)

if [[ $branch == main ]] {
  git pull --ff-only --autostash
  exit 0
}

git fetch origin main:main

if { git merge-base --is-ancestor main HEAD } {
  fn-exit-with 0 "up to date, sync skipped"
}

if { git merge-base --is-ancestor HEAD main } {
  git checkout main
  fn-exit-with 23 "branch '$branch' already merged; switched to main"
}

if ! { git rebase --autostash main } {
  print -u2 "rebase conflicts:"
  git diff --name-only --diff-filter=U | sed 's/^/  /' >&2
  fn-exit-with 22 "resolve conflicts, then \`git rebase --continue\` (or \`--abort\`)"
}
##[<] 🤖🤖
