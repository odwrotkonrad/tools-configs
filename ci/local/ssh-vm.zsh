#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail


typeset ip=$(tart ip configs) || { print -u2 "ssh-vm: vm not running"; exit 1 }

ssh -i ~/.ssh/id_local_access ko@$ip
