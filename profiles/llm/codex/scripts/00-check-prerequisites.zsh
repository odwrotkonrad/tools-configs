#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-log-msg

if (( ! ${+commands[ruby]} )) {
  fn-log-msg -t ruby -- "missing: install ruby with the system package manager before installing codex"
  exit 1
}
fn-log-msg -t ruby -- "found ($(ruby --version))"
##[<] 🤖🤖
