#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail nonomatch

##[>] 🤖🤖
typeset root=$(git -C ${0:A:h} rev-parse --show-toplevel)

export FPATH=$root/ci/zsh/functions:$FPATH
export PATH=$root/ci/python/scripts:$root/ci/zsh/scripts:$root/ci/zsh/scripts/installs:$root/ci/go/bin:/usr/local/bin:$PATH
export PYTHONPATH=$root/root/usr/local/scripts/python
export MYPYPATH=$root/root/usr/local/scripts/python
export GOMPLATE_CONFIG=$root/root/etc/gomplate/gomplate.yaml
export CHE_DRY_RUN=$MK_DRY_RUN

autoload -Uz fn-annotate-with-sections fn-print-with

[[ $1 == -c && -n $2 ]] || exit 0
typeset line=$2

if [[ -n $MK_DRY_RUN && ${line%% *} != che ]] {
  print -r -- "[dry-run] would run: $line"
  exit 0
}

typeset -a words=( ${(z)line} )
fn-annotate-with-sections ${~${(Q)words}}
##[<] 🤖🤖
