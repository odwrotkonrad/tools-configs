#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_vscode {
  brew install --cask visual-studio-code
}
fn-install-if-missing code install_vscode

brew list --cask font-jetbrains-mono >/dev/null 2>&1 || brew install --cask font-jetbrains-mono
##[<] 🤖🤖
