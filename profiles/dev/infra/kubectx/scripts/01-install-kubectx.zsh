#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing fn-is-os fn-is-arch

typeset version=0.11.0

#[why] kubectx has no version flag at all: presence check only, no version enforcement
function install_kubectx {
  local tmp=$(mktemp -d) os arch bin
  fn-is-os mac && os=darwin || os=linux
  fn-is-arch arm && arch=arm64 || arch=x86_64
  for bin ( kubectx kubens ) {
    curl --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -fsSL "https://github.com/ahmetb/kubectx/releases/download/v${version}/${bin}_v${version}_${os}_${arch}.tar.gz" | tar -xzf - -C $tmp $bin
    sudo install -m 0755 $tmp/$bin /usr/local/bin/$bin
  }
  rm -rf $tmp
}

fn-install-if-missing kubectx install_kubectx
##[<] 🤖🤖
