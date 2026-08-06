#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_kubectl {
  brew install kubectl
}
fn-install-if-missing kubectl install_kubectl
##[<] 🤖🤖
