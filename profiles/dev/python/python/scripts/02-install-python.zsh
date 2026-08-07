#!/bin/zsh
#>[what]
#   install python via pyenv (pip), set global, activate shims
#/[what]

emulate -LR zsh
setopt errexit pipefail

autoload -Uz fn-is-os

##[>] 🤖
fn-is-os mac || return 0  #[why] linux gets python3 via apt (misc/packages), no pyenv
pyenv install -s 3.14.5  #[what] -s skips if already installed
pyenv global 3.14.5
eval "$(pyenv init - zsh)"  #[why] activate shims in this non-interactive shell
##[<] 🤖
