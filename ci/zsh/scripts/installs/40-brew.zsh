#!/bin/zsh
#>[what]
#   install Homebrew. packages come from 01-pkgs, a fresh shell picking up
#   /opt/homebrew/bin via zshenv.
#/[what]

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-os
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

autoload -Uz fn-install-if-missing

##[>] 🤖
function install_brew {
  export NONINTERACTIVE=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
fn-install-if-missing brew install_brew
##[<]
