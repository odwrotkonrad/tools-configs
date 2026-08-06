#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

brew list openssh >/dev/null 2>&1 || brew install openssh
##[<] 🤖🤖
