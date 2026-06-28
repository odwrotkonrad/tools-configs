#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

typeset vm=macos-tahoe-vanilla-configs
typeset user=user
typeset key=~/.ssh/id_vm_access

function read_state {
  tart list --format json | jq -r ".[] | select(.Name == \"$1\") | .State"
}

case $(read_state $vm) {
  (running) ;;
  (stopped) tart run --no-graphics $vm & ;;
  (*) fn-exit-with 1 "vm-ssh: $vm not found" ;;
}

ssh -t -i $key \
  -o IdentitiesOnly=yes \
  -o PreferredAuthentications=publickey \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  $user@$(tart ip $vm) "$@"
