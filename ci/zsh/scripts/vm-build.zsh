#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)
typeset templates=$repo_root/ci/vm
typeset key=~/.ssh/id_vm_access

typeset name=$1
typeset -a packer_args=()
function build_args {
  local -a var_files=(
    $templates/$name.pkrvars.hcl(N)
    $templates/$name.local.pkrvars.hcl(N)
  )
  packer_args=( ${var_files[@]/#/-var-file=} )

  local bundle=$(mktemp -t configs.git.bundle)
  git -C $repo_root bundle create $bundle --all
  packer_args+=(-var bundle_path=$bundle)
}

function build_vm {
  local template=$templates/$name.pkr.hcl
  tart stop $name 2>/dev/null || true
  tart delete $name 2>/dev/null || true
  packer init $template
  packer build $packer_args $template
}

[[ -f $key ]] || ssh-keygen -t ecdsa -b 521 -N '' -C ${key:t} -f $key

build_args
build_vm

if [[ $name == macos-tahoe-vanilla-configs ]] {
  tart run --no-graphics $name &
}
##[<] 🤖🤖
