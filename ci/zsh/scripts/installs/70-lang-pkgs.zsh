#!/bin/zsh
#>[what] pip + gem packages (go/npm live in the Brewfile).
#/[what]

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-os
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

##[>] 🤖🤖
pip install -r /etc/python/requirements.txt
gem install ruby-lsp
##[<] 🤖🤖
