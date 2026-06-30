#!/bin/zsh
#>[what] pip + gem + go lang packages / LSPs (npm lives in the Brewfile). 🤖
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
python3.14 -m pip install -r /etc/python/requirements.txt
"$(brew --prefix ruby)/bin/gem" install ruby-lsp
PATH="/usr/local/go/bin:${PATH}" go install golang.org/x/tools/gopls@latest
##[<] 🤖🤖
