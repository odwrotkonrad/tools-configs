#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-write fn-exit-with

(( $+commands[codex] )) || fn-exit-with 1 "codex not installed: completions need the binary"
fn-comp-file-write codex _codex < <(codex completion zsh)
##[<] 🤖🤖
