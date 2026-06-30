#!/bin/zsh
#>[what] pip + gem + go lang packages / LSPs (npm lives in the Brewfile).
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
pip install -r /etc/python/requirements.txt
gem install ruby-lsp
PATH="/usr/local/go/bin:${PATH}" go install golang.org/x/tools/gopls@latest
##[<] 🤖🤖
