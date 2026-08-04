#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-write fn-is-os

fn-is-os mac || return 0
#[why] brew's git formula ships a bash-backed _git in site-functions that breaks under zsh; write the native pure-zsh _git into root-space completions, which precede brew in fpath
fn-comp-file-write git _git < /usr/share/zsh/${ZSH_VERSION}/functions/_git
##[<] 🤖🤖
