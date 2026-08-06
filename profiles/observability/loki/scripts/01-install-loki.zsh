#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_loki {
  brew install loki
}
fn-install-if-missing loki install_loki

function install_logcli {
  brew install logcli
}
fn-install-if-missing logcli install_logcli
##[<] 🤖🤖
