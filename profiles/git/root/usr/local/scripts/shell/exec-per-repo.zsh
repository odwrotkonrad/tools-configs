#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Run one command in every git repo under a root dir (default pwd),
#   concurrently: cwd = repo, GIT_WRAPPER_FG=1, colors off (NO_COLOR,
#   CLICOLOR, TERM=dumb), ANSI stripped at finish, stdout+stderr →
#   ~/.local/state/git-wrappers/exec-per-repo/<run pid>/<repo>_<pid>.log.
#   ## Progress on stderr: tty => in-place dashboard redrawn every 5s (header
#   done/count + overall status + clock + countdown bar; per repo
#   `### <repo> <emoji> <clock> (<pid>)`, log:, tail: last log line);
#   non-tty => spawn list + `done:` stream.
#   ## Report is a one-line summary (counts + total time); ## Failed
#   Executions blocks follow per failed repo (exit + dur, log path, last 10
#   log lines blockquoted). Exit: 0 all pass, 1 any fail, 2 bad
#   invocation.
#   A single command arg runs via `zsh -c` (quote a whole shell line: pipes,
#   `;`, &&); multiple args exec verbatim.
#   --include/--exclude: comma lists, basename or root-relative path,
#   ambiguous basename errors. --must-filter: AND of changes, off-main,
#   unsynced.
#   Usage: exec-per-repo [-C <dir>|--chpwd=<dir>] [--include=a,b]
#          [--exclude=a,b] [--must-filter=changes,off-main,unsynced]
#          <command> [args...]
#   Downstream: git, perl.
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
if (( $# == 1 )) {
  cmd=(zsh -c $1)
} else {
  cmd=("$@")
}

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

log_dir=${XDG_STATE_HOME:-$HOME/.local/state}/git-wrappers/exec-per-repo/$$
mkdir -p $log_dir

zmodload zsh/datetime
zmodload zsh/system
setopt extendedglob
fmt_dur() { printf '%dm%02ds' $(( $1 / 60 )) $(( $1 % 60 )) }
bold=$'\e[1m' unbold=$'\e[0m'

typeset -A pid_of status_of start_of elapsed_of log_of
run_start=$EPOCHSECONDS
for repo ($repos) {
  start_of[$repo]=$EPOCHSECONDS
  ( exec > $log_dir/${repo//\//__}_$sysparams[pid].log 2>&1
    cd $dir_of[$repo] && export GIT_WRAPPER_FG=1 NO_COLOR=1 CLICOLOR=0 TERM=dumb && "$cmd[@]" ) &
  pid=$!
  pid_of[$repo]=$pid
  log_of[$repo]=$log_dir/${repo//\//__}_$pid.log
}

pending=($repos)
reap_finished() {
  reply=()
  for repo ($pending) {
    kill -0 $pid_of[$repo] 2>/dev/null && continue
    wait $pid_of[$repo]
    status_of[$repo]=$?
    elapsed_of[$repo]=$(( EPOCHSECONDS - start_of[$repo] ))
    perl -i -pe 's/\e\[[0-9;?]*[A-Za-z]//g' $log_of[$repo] 2>/dev/null
    reply+=($repo)
    pending=(${pending:#$repo})
  }
}

progress_header() {
  local fill=$1 repo overall
  if (( $#pending )) {
    overall=🕐
  } else {
    overall=✅
    for repo ($repos) (( status_of[$repo] )) && overall=❌
  }
  local bar="${(pl:$fill::▰:):-}${(pl:$(( 5 - fill ))::▱:):-}"
  (( $#pending )) || bar=""
  print -r -- "${bold}## Progress $(( $#repos - $#pending ))/$#repos $overall $(fmt_dur $(( EPOCHSECONDS - run_start ))) ($$) $bar${unbold}"
}

render_progress() {
  local repo log line emoji clock
  local cols=${COLUMNS:-$(tput cols 2>/dev/null)}
  : ${cols:=120}
  (( cols -= 4 ))
  draw_lines=( "$(progress_header 0)" "" )
  for repo ($repos) {
    log=$log_of[$repo]
    if (( ${+status_of[$repo]} )) {
      (( status_of[$repo] )) && emoji=❌ || emoji=✅
      clock=$(fmt_dur $elapsed_of[$repo])
    } else {
      emoji=🕐
      clock=$(fmt_dur $(( EPOCHSECONDS - start_of[$repo] )))
    }
    draw_lines+=( "${bold}### $repo $emoji $clock ($pid_of[$repo])${unbold}" "log: $log" )
    line=${${:-"$(tail -n 1 $log 2>/dev/null)"}//$'\r'/}
    line=${line//$'\e'\[[0-9;]#[a-zA-Z]/}
    draw_lines+=( "tail: > ${line[1,cols]}" "" )
  }
}

if [[ -t 2 ]] {
  typeset -a draw_lines
  drawn=0 tick=0
  while (( 1 )) {
    reap_finished
    if (( tick % 5 == 0 || ! $#pending )) {
      render_progress
      (( drawn )) && printf '\e[%dA\e[0J' $drawn >&2
      print -lru2 -- "$draw_lines[@]"
      drawn=$#draw_lines
    } else {
      printf '\e[%dA\r\e[2K%s\e[%dB\r' $drawn "$(progress_header $(( tick % 5 )))" $drawn >&2
    }
    (( $#pending )) || break
    sleep 1
    (( tick += 1 ))
  }
} else {
  print -ru2 -- "## Progress"
  for repo ($repos) {
    print -ru2 -- "🕐 $repo ($pid_of[$repo])"
    print -ru2 -- "log: $log_of[$repo]"
    print -ru2 -- ""
  }
  while (( $#pending )) {
    reap_finished
    for repo ($reply) {
      (( status_of[$repo] == 0 )) && emoji=✅ || emoji=❌
      print -ru2 -- "done: $emoji $(fmt_dur $elapsed_of[$repo]) $repo"
    }
    (( $#pending )) && sleep 1
  }
}

failed=()
for repo ($repos) (( status_of[$repo] )) && failed+=($repo)

print -r -- "${bold}## Report${unbold}"
print -r -- "repos: $#repos, ✅ $(( $#repos - $#failed )), ❌ $#failed, total $(fmt_dur $(( EPOCHSECONDS - run_start )))"
if (( $#failed )) {
  print -r -- $'\n'"${bold}## Failed Executions${unbold}"
  for repo ($failed) {
    log=$log_of[$repo]
    print -r -- $'\n'"${bold}### $repo ❌ (exit $status_of[$repo]) $(fmt_dur $elapsed_of[$repo])${unbold}"
    print -r -- "log: $log"
    print -r -- "tail:"
    for line (${(f)"$(tail -n 10 $log)"}) {
      print -r -- "> ${${line//$'\r'/}//$'\e'\[[0-9;]#[a-zA-Z]/}"
    }
  }
}
(( $#failed )) && exit 1
exit 0
##[<] 🤖🤖
