#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

brew list ruby >/dev/null 2>&1 || brew install ruby
##[<] 🤖🤖
