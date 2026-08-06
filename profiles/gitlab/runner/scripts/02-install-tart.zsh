#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_packer {
  brew install hashicorp/tap/packer
}
fn-install-if-missing packer install_packer

function install_tart {
  brew tap cirruslabs/cli
  brew install cirruslabs/cli/tart cirruslabs/cli/gitlab-tart-executor
}
fn-install-if-missing tart install_tart
##[<] 🤖🤖
