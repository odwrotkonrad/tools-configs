#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-fetch

fn-comp-file-fetch kubectx _kubectx https://raw.githubusercontent.com/ahmetb/kubectx/v0.11.0/completion/_kubectx.zsh
fn-comp-file-fetch kubens _kubens https://raw.githubusercontent.com/ahmetb/kubectx/v0.11.0/completion/_kubens.zsh
##[<] 🤖🤖
