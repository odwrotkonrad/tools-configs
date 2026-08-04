#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-write fn-exit-with

(( $+commands[kind] )) || fn-exit-with 1 "kind not installed: completions need the binary"
fn-comp-file-write kind _kind < <(kind completion zsh)
##[<] 🤖🤖
