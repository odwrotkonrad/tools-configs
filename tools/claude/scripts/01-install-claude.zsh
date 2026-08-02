#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_claude {
  curl -fsSL https://claude.ai/install.sh | bash
}
fn-install-if-missing claude install_claude
##[<] 🤖🤖
