#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset vm=macos-tahoe-vanilla-configs
typeset user=user
typeset key=~/.ssh/id_vm_access
typeset vm_repo=/Users/$user/projects/configs

function read_state {
  tart list --format json | jq -r ".[] | select(.Name == \"$1\") | .State"
}

case $(read_state $vm) {
  (running) ;;
  (stopped) tart run --no-graphics $vm & ;;
  (*) fn-exit-with 1 "${0:t}: $vm not found" ;;
}

#[what] -c <line>: run the line in the vm repo dir; else interactive
typeset -a cmd=( "$@" )
[[ $1 == -c && -n $2 ]] && cmd=( "cd $vm_repo && $2" )

for attempt ( 1 2 3 ) {
  ssh -t -i $key \
    -o IdentitiesOnly=yes \
    -o PreferredAuthentications=publickey \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o SendEnv=OP_SERVICE_ACCOUNT_TOKEN \
    $user@$(tart ip $vm) "${cmd[@]}" && return
  (( attempt < 3 )) && sleep 2
}
fn-exit-with 1 "${0:t}: ssh failed after 3 attempts"
##[<] 🤖🤖
