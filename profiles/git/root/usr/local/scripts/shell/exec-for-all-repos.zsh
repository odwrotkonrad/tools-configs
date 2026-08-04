#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Discover every git repo under a root dir (default pwd), run one command in
#   each concurrently (cwd = repo, GIT_WRAPPER_FG=1 exported, stdout+stderr
#   captured to ~/.local/state/git-wrappers/exec-for-all-repos/<repo>.log),
#   then print a per-repo ✅/❌ report; failed repos dump their captured
#   output inline. Exit 0 when all pass, 1 otherwise, 2 on bad invocation.
#   --include/--exclude match repo basename or root-relative path (comma
#   lists); ambiguous basename errors. --must-filter=changes,off-main,unsynced
#   keeps only repos satisfying every listed condition.
#   Usage: exec-for-all-repos [-C <dir>|--chpwd=<dir>] [--include=a,b]
#          [--exclude=a,b] [--must-filter=changes,off-main,unsynced]
#          <command> [args...]
#   Downstream: git.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -o pipefail

self=${0:t}
usage() {
  print -ru2 -- "usage: $self [-C <dir>|--chpwd=<dir>] [--include=a,b] [--exclude=a,b] [--must-filter=changes,off-main,unsynced] <command> [args...]"
  exit 2
}

root=$PWD
include=() exclude=() must=()
while (( $# )) {
  case $1 {
    -C) (( $# >= 2 )) || usage; root=$2; shift 2 ;;
    --chpwd=*) root=${1#*=}; shift ;;
    --include=*) include+=(${(s:,:)${1#*=}}); shift ;;
    --exclude=*) exclude+=(${(s:,:)${1#*=}}); shift ;;
    --must-filter=*) must+=(${(s:,:)${1#*=}}); shift ;;
    -*) usage ;;
    *) break ;;
  }
}
(( $# )) || usage
cmd=("$@")

for f ($must) {
  case $f {
    changes|off-main|unsynced) ;;
    *) print -ru2 -- "$self: unknown --must-filter value: $f"; exit 2 ;;
  }
}

root=${root:A}
[[ -d $root ]] || { print -ru2 -- "$self: no such directory: $root"; exit 2 }

repos=()
typeset -A dir_of
for gitent (${(f)"$(find $root -name .git -prune -print 2>/dev/null | sort)"}) {
  dir=${gitent:h}
  rel=${dir#$root/}
  [[ $dir == $root ]] && rel=${root:t}
  repos+=($rel)
  dir_of[$rel]=$dir
}
(( $#repos )) || { print -ru2 -- "$self: no repos found under $root"; exit 2 }

resolve_selector() {
  local tok=$1
  hit=
  if [[ $tok == */* ]] {
    [[ -n ${repos[(r)$tok]} ]] && hit=$tok
    return
  }
  local hits=(${(M)repos:#(*/|)$tok})
  if (( $#hits > 1 )) {
    print -ru2 -- "$self: ambiguous name '$tok' matches: ${(j:, :)hits}"
    exit 2
  }
  (( $#hits )) && hit=$hits[1]
}

if (( $#include )) {
  selected=()
  for tok ($include) {
    resolve_selector $tok
    [[ -z $hit || -n ${selected[(r)$hit]} ]] || selected+=($hit)
  }
  repos=(${repos:*selected})
}
for tok ($exclude) {
  resolve_selector $tok
  [[ -n $hit ]] && repos=(${repos:#$hit})
}

if (( $#must )) {
  kept=()
  for repo ($repos) {
    ok=1
    for f ($must) {
      case $f {
        changes)
          [[ -n $(git -C $dir_of[$repo] status --porcelain) ]] || ok=0 ;;
        off-main)
          [[ $(git -C $dir_of[$repo] rev-parse --abbrev-ref HEAD) != main ]] || ok=0 ;;
        unsynced)
          counts=$(git -C $dir_of[$repo] rev-list --left-right --count '@{u}...HEAD' 2>/dev/null) &&
            [[ $counts == $'0\t0' ]] && ok=0 ;;
      }
      (( ok )) || break
    }
    (( ok )) && kept+=($repo)
  }
  repos=($kept)
}
(( $#repos )) || { print -r -- "no repos matched"; exit 0 }

log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/git-wrappers/exec-for-all-repos
mkdir -p $log_dir

typeset -A pid_of status_of
for repo ($repos) {
  log=$log_dir/${repo//\//__}.log
  ( cd $dir_of[$repo] && export GIT_WRAPPER_FG=1 && "$cmd[@]" ) &> $log &
  pid=$!
  pid_of[$repo]=$pid
}
for repo ($repos) {
  wait $pid_of[$repo]
  status_of[$repo]=$?
}

print -r -- "## Report"
failed=()
for repo ($repos) {
  if (( status_of[$repo] == 0 )) {
    print -r -- "$repo: ✅"
  } else {
    print -r -- "$repo: ❌ (exit $status_of[$repo])"
    failed+=($repo)
  }
}
for repo ($failed) {
  print -r -- $'\n'"## Output: $repo"
  cat $log_dir/${repo//\//__}.log
}
(( $#failed )) && exit 1
exit 0
##[<] 🤖🤖
