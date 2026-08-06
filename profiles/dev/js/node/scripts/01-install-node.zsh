#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

typeset -a pkgs=( node corepack typescript typescript-language-server )
for pkg ( $pkgs ) {
  brew list $pkg >/dev/null 2>&1 || brew install $pkg
}
##[<] 🤖🤖
