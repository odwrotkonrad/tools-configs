#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)
typeset image=ci-linux:local
typeset src=/mnt/configs-src
typeset workdir=/builds/konradodwrot/configs

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"
docker image inspect $image >/dev/null 2>&1 || fn-exit-with 1 "${0:t}: $image not built (run: make run-repo-ci-virt-linux-build)"

#[what] -c <line>: run the line in the workdir as ko; else interactive zsh
#[why] pass the line via env (not arg interpolation) to keep its quoting intact
typeset -a env_args=( -e CI=1 )
typeset -a ko_cmd=( zsh )
[[ $1 == -c && -n $2 ]] && { env_args+=( -e "RUN_CMD=$2" ); ko_cmd=( sh -c 'cd "$WORKDIR" && eval "$RUN_CMD"' ) }

#[what] allocate a tty only when stdin is one (interactive ssh, not piped CI)
typeset -a tty=()
[[ -t 0 ]] && tty=( -it )

#[why] copy the read-only host repo to a ko-owned workdir, then chown the COPY
#   (not the host mount): host tree stays clean, dodges docker-desktop's
#   no-chown-on-bind-mount and overlay-over-virtiofs limits
docker run --rm $tty \
  -v "${repo_root}:${src}:ro" \
  -e "SRC=$src" -e "WORKDIR=$workdir" $env_args \
  $image \
  sh -c 'sudo mkdir -p "$(dirname "$WORKDIR")" && sudo cp -a "$SRC" "$WORKDIR" && sudo chown -R ko "$WORKDIR" && exec sudo -u ko --preserve-env=CI,WORKDIR,RUN_CMD "$@"' _ "${ko_cmd[@]}"
##[<] 🤖🤖
