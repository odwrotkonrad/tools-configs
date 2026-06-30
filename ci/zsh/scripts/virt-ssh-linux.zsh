#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)
typeset image=ci-linux:local
typeset dockerfile=$repo_root/ci/Dockerfile.linux
typeset src=/mnt/configs-src
typeset workdir=/builds/konradodwrot/configs

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

docker build -f $dockerfile -t $image $repo_root

#[what] -c <line>: run the line in the workdir; else interactive shell
typeset -a cmd=( zsh )
[[ $1 == -c && -n $2 ]] && cmd=( sh -c "cd $workdir && $2" )

#[what] allocate a tty only when stdin is one (interactive ssh, not piped CI)
typeset -a tty=()
[[ -t 0 ]] && tty=( -it )

#[why] copy the read-only host repo to a ko-owned workdir, then chown the COPY
#   (not the host mount): host tree stays clean, dodges docker-desktop's
#   no-chown-on-bind-mount and overlay-over-virtiofs limits
typeset setup="mkdir -p ${workdir:h} && cp -a $src $workdir && chown -R ko $workdir"

docker run --rm $tty \
  -v $repo_root:$src:ro \
  -e CI=1 \
  $image \
  sh -c "sudo sh -c '$setup' && exec sudo -u ko --preserve-env=CI ${cmd[*]}"
##[<] 🤖🤖
