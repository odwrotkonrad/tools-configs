#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Merge <example> defaults with <env> overlay (env wins), print sorted KEY=VALUE. Skips blank, `#` lines. Missing <env>: defaults only.
#   Usage: tpl-render-merge-upsert-env <env> <example>
#   Upstream: gomplate `tplRenderMergeUpsertEnv`. Downstream: <env>, <example>.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
setopt err_return extended_glob

autoload -Uz fn-exit-with

env=$1
example=$2

[[ -n $env && -n $example ]] || fn-exit-with 11 "usage: ${0:t} <env> <example>"
[[ -f $example ]] || fn-exit-with 13 "file not found: $example"

typeset -A merged

read_into() {
  local line key
  [[ -f $1 ]] || return 0
  while IFS= read -r line || [[ -n $line ]]; do
    line=${${line##[[:space:]]##}%%[[:space:]]##}
    [[ -z $line || $line == \#* ]] && continue
    key=${line%%=*}
    merged[$key]=${line#*=}
  done < $1
}

read_into $example
read_into $env

for key in ${(ok)merged}; print -r -- "$key=${merged[$key]}"
##[<] 🤖🤖
