#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing fn-is-os
fn-is-os mac || return 0
setopt errexit pipefail

function install_az {
  brew tap azure/azure-cli
  brew install --cask azure/azure-cli/azure-cli-preview
}
fn-install-if-missing az install_az
##[<] 🤖🤖
