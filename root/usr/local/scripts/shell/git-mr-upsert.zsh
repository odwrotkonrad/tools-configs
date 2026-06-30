#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Branch-upsert (sync + name), push, then create/update the MR/PR with llm text.
#   left on main (merged, nothing new): exit 0.
#   push: always plain (never force in automation); diverged remote -> push fails,
#     error tails into the log, push manually.
#   cli: gitlab.com -> glab | github.com -> gh.
#   upsert: no open MR -> draft | open same source -> edit | changed source -> close + recreate.
#   Usage: git-mr-upsert
#   Downstream: git-branch-name-upsert, llm-git-mr-suggest, git, glab/gh.
#   Exit Codes: 22 sync conflicts
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e

log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/git-wrappers
mkdir -p $log_dir
exec >>$log_dir/${0:t:r}.log 2>&1
print -r -- "=== ${0:t} $(date +%FT%T) ==="

git-branch-name-upsert.zsh && rc=0 || rc=$?
(( rc == 22 )) && exit 22

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ $branch == main ]] {
  print -r -- "on main, nothing to MR"
  exit 0
}
##[<] 🤖🤖

##[>] push 🤖🤖
git push -u origin HEAD
##[<] push 🤖🤖

##[>] generate text 🤖🤖
out=$(llm-git-mr-suggest.zsh)
title=$(jq -r .title <<< $out)
description=$(jq -r .description <<< $out)
print -r -- "title: $title"
##[<] generate text 🤖🤖

##[>] cli select 🤖🤖
case $(git remote get-url origin) {
  *gitlab.com*) cli=glab ;;
  *github.com*) cli=gh ;;
  *) print -r -- "unknown remote host, aborting"; exit 1 ;;
}
print -r -- "cli: $cli"
##[<] cli select 🤖🤖

##[>] upsert mr/pr 🤖🤖
if [[ $cli == glab ]] {
  open_source=$(glab mr view -F json --jq '.source_branch' 2>/dev/null || true)
  if [[ -z $open_source ]] {
    glab mr create --draft --source-branch $branch --title $title --description $description --yes
  } elif [[ $open_source == $branch ]] {
    glab mr update --title $title --description $description
  } else {
    glab mr close 2>/dev/null || true
    glab mr create --draft --source-branch $branch --title $title --description $description --yes
  }
} else {
  open_source=$(gh pr view --json headRefName --jq '.headRefName' 2>/dev/null || true)
  if [[ -z $open_source ]] {
    gh pr create --draft --head $branch --title $title --body $description
  } elif [[ $open_source == $branch ]] {
    gh pr edit --title $title --body $description
  } else {
    gh pr close $open_source 2>/dev/null || true
    gh pr create --draft --head $branch --title $title --body $description
  }
}
##[<] upsert mr/pr 🤖🤖
