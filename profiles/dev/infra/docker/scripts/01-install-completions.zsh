#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-write

(( $+commands[docker] )) || return 0
fn-comp-file-write docker _docker < <(docker completion zsh)
##[<] 🤖🤖
