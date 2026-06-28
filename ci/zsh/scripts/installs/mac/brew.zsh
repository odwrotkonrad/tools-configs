#!/bin/zsh
#>[what]
#   install Homebrew (the package manager). packages come from 01-pkgs,
#   which runs as a fresh shell that picks up /opt/homebrew/bin via zshenv.
#/[what]

emulate -LR zsh
setopt errexit pipefail

autoload -Uz fn-install-if-missing

##[>] 🤖
function install_brew {
  export NONINTERACTIVE=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
fn-install-if-missing brew install_brew
##[<]
