#!/bin/zsh
#>[≟] build the configs vm from configs-base: git clone the repo, boot. #/[≟]

emulate -LR zsh
setopt errexit pipefail

#[……] 🤖🤖
typeset repo_root=$HOME/projects/configs
typeset templates=$repo_root/ci/local/vm-template

# bundle the repo (committed history) for the derivative to clone
typeset bundle=$(mktemp -t configs.git.bundle)
git -C $repo_root bundle create $bundle --all

# build derivative (clone base + git clone the repo) and boot
tart delete configs 2>/dev/null || true
packer build -var bundle_path=$bundle $templates/configs.pkr.hcl
tart run --no-graphics configs &
#[⫶⫶] 🤖🤖

# ssh -i /Users/ko/.ssh/id_local_access ko@$(tart ip configs)
