#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-comp-file-fetch

fn-comp-file-fetch go _golang https://raw.githubusercontent.com/zsh-users/zsh-completions/398b4b74775102da7bc6a510a08d0914592f9e62/src/_golang
##[<] 🤖🤖
