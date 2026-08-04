#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

PATH="/usr/local/go/bin:${PATH}" GOPATH=${HOME}/go go install golang.org/x/tools/gopls@latest
##[<] 🤖🤖
