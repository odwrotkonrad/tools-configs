#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing

function install_goreleaser {
  brew install goreleaser
}
fn-install-if-missing goreleaser install_goreleaser

function install_zig {
  brew install zig
}
fn-install-if-missing zig install_zig
##[<] 🤖🤖
