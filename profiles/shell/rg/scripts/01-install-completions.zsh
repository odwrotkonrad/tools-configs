#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-write fn-exit-with

(( $+commands[rg] )) || fn-exit-with 1 "rg not installed: completions need the binary"
fn-comp-file-write rg _rg < <(rg --generate=complete-zsh)
##[<] 🤖🤖
