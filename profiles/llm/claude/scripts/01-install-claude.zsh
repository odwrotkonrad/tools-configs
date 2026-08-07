#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing fn-is-os

fn-is-os mac || return 0

function install_claude {
  brew install --cask claude-code
}
fn-install-if-missing claude install_claude
##[<] 🤖🤖
