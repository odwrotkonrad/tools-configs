#!/bin/zsh
#>[≟] build the configs-base image (ko, key, CLT) — slow stable layer, run once. #/[≟]

emulate -LR zsh
setopt errexit pipefail

#[……] 🤖🤖
typeset key=~/.ssh/id_local_access
typeset templates=$HOME/projects/configs/ci/local/vm-template

# create ssh key pair if not existing
[[ -f $key ]] || ssh-keygen -N '' -C ${key:t} -f $key

# build base image
tart stop configs-base 2>/dev/null || true
tart delete configs-base 2>/dev/null || true
packer build $templates/configs-base.pkr.hcl
#[⫶⫶] 🤖🤖
