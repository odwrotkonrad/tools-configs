#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Branch-upsert (sync + name), push, then create/update the MR/PR with llm text.
#   left on main (merged, nothing new): exit 24, nothing to MR.
#   unchanged since last run (remote tip == HEAD, an MR/PR already open for the
#     branch): exit 24 before the llm call, nothing to re-say.
#   push: plain first; rejected (sync rebased already-pushed commits) -> re-fetch and
#     force-with-lease pinned to the fetched tip, but only when git cherry proves the
#     remote holds nothing this branch lacks; remote-only commits -> exit 1, push manually.
#   cli: gitlab.com -> glab | github.com -> gh.
#   upsert: match = open MR/PR whose head commits are patch-equivalent (git cherry) to
#     commits in this branch and not yet in main;
#     other-source matches close (superseded) | same-source match -> edit | none -> create.
#   Usage: git-mr-upsert
#   Downstream: git-branch-name-upsert, llm-git-mr-suggest, git, glab/gh.
#   Exit Codes: 22 sync conflicts · 24 skipped (nothing to MR)
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

git-branch-name-upsert.zsh && rc=0 || rc=$?
(( rc == 22 )) && exit 22
(( rc == 0 || rc == 24 )) || exit $rc

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ $branch == main ]] fn-exit-with 24 "on main, nothing to MR"
##[<] 🤖🤖

##[>] cli select 🤖🤖
case $(git remote get-url origin) {
  *gitlab.com*) cli=glab ;;
  *github.com*) cli=gh ;;
  *) print -r -- "unknown remote host, aborting"; exit 1 ;;
}
print -r -- "cli: $cli"
##[<] cli select 🤖🤖

##[>] 🤖🤖 unchanged since last run: remote tip already this commit, MR already open
git fetch origin $branch >/dev/null 2>&1 || true
if [[ $(git rev-parse HEAD) == $(git rev-parse FETCH_HEAD 2>/dev/null) ]] {
  if [[ $cli == glab ]] {
    open_for_branch=$(glab mr list --source-branch $branch -F json | jq -r 'length')
  } else {
    open_for_branch=$(gh pr list --head $branch --json number --jq 'length')
  }
  (( open_for_branch )) && fn-exit-with 24 "no changes since last run, MR already open"
}
##[<] 🤖🤖

##[>] push 🤖🤖
#[why] sync rebases onto main, rewriting already-pushed commits: the remote tip is then a
#      stale twin of a local commit, so a plain push is rejected non-fast-forward
if ! { git push -u origin HEAD } {
  git fetch origin $branch || { print -r -- "no remote $branch to reconcile, push failed"; exit 1 }
  if [[ -n ${(M)${(f)"$(git cherry HEAD FETCH_HEAD)"}:#+*} ]] {
    print -r -- "remote $branch holds commits absent here, refusing to force: push manually"
    exit 1
  }
  print -r -- "remote $branch is a pre-rebase twin, force-with-lease"
  git push --force-with-lease=$branch:$(git rev-parse FETCH_HEAD) -u origin HEAD
}
##[<] push 🤖🤖

##[>] generate text 🤖🤖
out=$(llm-git-mr-suggest.zsh)
title=$(jq -r .title <<< $out)
description=$(jq -r .description <<< $out)
print -r -- "title: $title"
##[<] generate text 🤖🤖

##[>] upsert mr/pr 🤖🤖
git fetch --prune origin

#[what] match = open MR/PR whose head commits are patch-equivalent to commits in this branch and not yet in origin/main
mr_match() {
  git rev-parse --quiet --verify origin/$1 >/dev/null || return 1
  [[ -z ${(M)${(f)"$(git cherry HEAD origin/$1)"}:#+*} ]] || return 1
  [[ -n ${(M)${(f)"$(git cherry origin/main origin/$1)"}:#+*} ]]
}

#[what] matches on other sources are superseded by this branch: always closed
if [[ $cli == glab ]] {
  #[why] by iid, never branch name: a branch selector is ambiguous when two open MRs share the source branch; the extra same-branch MR closes as superseded too
  typeset -a open_mrs matched_mrs
  open_mrs=( ${(f)"$(glab mr list -F json | jq -r '.[] | "\(.iid)\t\(.source_branch)"')"} )
  for mr in $open_mrs; do
    mr_match ${mr#*$'\t'} && matched_mrs+=( $mr )
  done
  print -r -- "open: ${open_mrs//$'\t'/:} | matched: ${matched_mrs//$'\t'/:}"

  #[why] glab mr close (1.105.0) wrongly enforces merge checks (ci_must_pass): close via api (https://gitlab.com/gitlab-org/cli/-/work_items/8400)
  keep_iid=
  for mr in $matched_mrs; do
    iid=${mr%%$'\t'*} src=${mr#*$'\t'}
    if [[ $src == $branch && -z $keep_iid ]] { keep_iid=$iid; continue }
    print -r -- "closing superseded: !$iid ($src)"
    glab api -X PUT "projects/:id/merge_requests/$iid" -f state_event=close >/dev/null
  done
  if [[ -n $keep_iid ]] {
    glab mr update $keep_iid --title $title --description $description
  } else {
    glab mr create --source-branch $branch --title $title --description $description --yes
  }
} else {
  typeset -a open_srcs matched_srcs
  open_srcs=( ${(f)"$(gh pr list --json headRefName --jq '.[].headRefName')"} )
  for src in $open_srcs; do
    mr_match $src && matched_srcs+=( $src )
  done
  print -r -- "open: $open_srcs | matched: $matched_srcs"
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
