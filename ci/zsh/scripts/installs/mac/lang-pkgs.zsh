#!/bin/zsh
#>[what] pip + gem packages (go/npm live in the Brewfile).
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
pip install -r /etc/python/requirements.txt
gem install ruby-lsp
##[<] 🤖🤖
