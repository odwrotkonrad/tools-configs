#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-fetch

fn-comp-file-fetch claude _claude https://raw.githubusercontent.com/wbingli/zsh-claudecode-completion/01f50d4a8a98b91cf6d9359deb37d60668c49806/_claude
##[<] 🤖🤖
