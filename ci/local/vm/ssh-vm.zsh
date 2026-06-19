#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz exit-with

typeset vm=ko-macos-tahoe-vanilla-configs-local
typeset user=$USER
typeset key=~/.ssh/id_vm_access

function read_state {
  tart list --format json | jq -r ".[] | select(.Name == \"$1\") | .State"
}

case $(read_state $vm) {
  (running) ;;
  (stopped) tart run --no-graphics $vm & ;;
  (*) exit-with 1 "ssh-vm: $vm not found" ;;
}

ssh -t -i $key \
  -o IdentitiesOnly=yes \
  -o PreferredAuthentications=publickey \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  $user@$(tart ip $vm) "$@"
