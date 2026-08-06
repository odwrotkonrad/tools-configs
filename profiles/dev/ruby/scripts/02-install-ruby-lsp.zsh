#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

"$(brew --prefix ruby)/bin/gem" install ruby-lsp
##[<] 🤖🤖
