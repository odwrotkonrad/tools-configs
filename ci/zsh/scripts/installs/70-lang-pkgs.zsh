#!/bin/zsh
#>[what] gem + go lang packages / LSPs (npm lives in the Brewfile). 🤖
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
"$(brew --prefix ruby)/bin/gem" install ruby-lsp
PATH="/usr/local/go/bin:${PATH}" GOPATH=${HOME}/go go install golang.org/x/tools/gopls@latest
##[<] 🤖🤖
