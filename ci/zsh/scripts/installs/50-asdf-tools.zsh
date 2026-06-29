#!/bin/zsh
#>[what]
#   install asdf plugins + the tool versions pinned in .tool-versions
#/[what]

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-os
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

##[>] 🤖
typeset -A plugins=(
  terraform https://github.com/asdf-community/asdf-hashicorp.git
  kubectl   https://github.com/asdf-community/asdf-kubectl.git
  kubectx   https://gitlab.com/wt0f/asdf-kubectx.git
  pnpm      https://github.com/jonathanmorley/asdf-pnpm.git
)
for name url ( ${(kv)plugins} ) asdf plugin add $name $url
asdf install
##[<] 🤖
