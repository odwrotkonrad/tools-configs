#!/bin/zsh
#>[what]
#   install aws cli v2 per os/arch via fn-is-os/fn-is-arch predicates
#/[what]

emulate -LR zsh
setopt errexit

autoload -Uz fn-install-if-missing fn-exit-with fn-is-os fn-is-arch

function install_aws {
  local tmp=$(mktemp -d)
  cd $tmp

  if { fn-is-os mac } {
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    return
  }

  if { ! fn-is-os linux } fn-exit-with 1 "unknown system: $(uname -s)"

  local arch
  case $(uname -m) {
    (arm64|aarch64) arch=aarch64 ;;
    (x86_64|amd64)  arch=x86_64 ;;
    (*) fn-exit-with 1 "unknown arch: $(uname -m)" ;;
  }

  curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install --update
}

fn-install-if-missing aws install_aws
