#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
#[why] shared ci-linux base now lives in infra/ci-images; pull it and tag local instead of building from a repo-local Dockerfile
typeset image=ci-linux:local
typeset shared=registry.gitlab.com/konradodwrot/infra/ci-images/ci-linux:v0.0.7

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

docker pull $shared
docker tag $shared $image
##[<] 🤖🤖
