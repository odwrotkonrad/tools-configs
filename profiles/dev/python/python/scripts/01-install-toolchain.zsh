#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

typeset -a pkgs=( pyenv python@3.14 pipx uv pyright )
for pkg ( $pkgs ) {
  brew list $pkg >/dev/null 2>&1 || brew install $pkg
}
##[<] 🤖🤖
