#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_gh {
  brew install gh
}
fn-install-if-missing gh install_gh
##[<] 🤖🤖
