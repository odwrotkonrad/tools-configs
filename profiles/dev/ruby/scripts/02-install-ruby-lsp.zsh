#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-is-os

if { fn-is-os mac } {
  "$(brew --prefix ruby)/bin/gem" install ruby-lsp
} else {
  typeset -a sudo_cmd=( )
  (( UID )) && sudo_cmd=( sudo )
  $sudo_cmd gem install ruby-lsp
}
##[<] 🤖🤖
