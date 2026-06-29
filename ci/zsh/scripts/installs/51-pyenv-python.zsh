#!/bin/zsh
#>[what]
#   install python via pyenv (pip), set global, activate shims
#/[what]

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-os
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

##[>] 🤖
pyenv install -s 3.14.5  #[what] -s skips if already installed
pyenv global 3.14.5
eval "$(pyenv init - zsh)"  #[why] activate shims in this non-interactive shell
##[<] 🤖
