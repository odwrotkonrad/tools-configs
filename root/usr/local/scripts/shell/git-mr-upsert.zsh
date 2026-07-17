#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Branch-upsert (sync + name), push, then create/update the MR/PR with llm text.
#   left on main (merged, nothing new): exit 0.
#   push: always plain (never force in automation); diverged remote -> push fails,
#     error tails into the log, push manually.
#   cli: gitlab.com -> glab | github.com -> gh.
#   upsert: match = open MR/PR whose head commits are patch-equivalent (git cherry) to
#     commits in this branch and not yet in main;
#     other-source matches close (superseded) | same-source match -> edit | none -> create.
#   Usage: git-mr-upsert
#   Downstream: git-branch-name-upsert, llm-git-mr-suggest, git, glab/gh.
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
git fetch --prune origin

#[what] match = open MR/PR whose head commits are patch-equivalent to commits in this branch and not yet in origin/main
typeset -a open_srcs matched_srcs
if [[ $cli == glab ]] {
  open_srcs=( ${(f)"$(glab mr list -F json | jq -r '.[].source_branch')"} )
} else {
  open_srcs=( ${(f)"$(gh pr list --json headRefName --jq '.[].headRefName')"} )
}
for src in $open_srcs; do
  if ! git rev-parse --quiet --verify origin/$src >/dev/null; then continue; fi
  if [[ -n ${(M)${(f)"$(git cherry HEAD origin/$src)"}:#+*} ]]; then continue; fi
  if [[ -z ${(M)${(f)"$(git cherry origin/main origin/$src)"}:#+*} ]]; then continue; fi
  matched_srcs+=( $src )
done
print -r -- "open: $open_srcs | matched: $matched_srcs"

#[what] matches on other sources are superseded by this branch: always closed
if [[ $cli == glab ]] {
  #[why] glab mr close (1.105.0) wrongly enforces merge checks (ci_must_pass): close via api
  for src in ${matched_srcs:#$branch}; do
    print -r -- "closing superseded: $src"
    iid=$(glab mr view $src --output json | jq -r .iid)
    glab api -X PUT "projects/:id/merge_requests/$iid" -f state_event=close >/dev/null
    # glab api must be used instead of glab mr close (https://gitlab.com/gitlab-org/cli/-/work_items/8400)
  done
  if (( ${matched_srcs[(Ie)$branch]} )) {
    glab mr update $branch --title $title --description $description
  } else {
    glab mr create --source-branch $branch --title $title --description $description --yes
  }
} else {
  for src in ${matched_srcs:#$branch}; do
    print -r -- "closing superseded: $src"
    gh pr close $src
  done
  if (( ${matched_srcs[(Ie)$branch]} )) {
    gh pr edit $branch --title $title --body $description
  } else {
    gh pr create --head $branch --title $title --body $description
  }
}
##[<] upsert mr/pr 🤖🤖
