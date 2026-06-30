#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)
typeset image=ci-linux:local
typeset dockerfile=$repo_root/ci/Dockerfile.linux

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

docker build -f $dockerfile -t $image $repo_root
##[<] 🤖🤖
