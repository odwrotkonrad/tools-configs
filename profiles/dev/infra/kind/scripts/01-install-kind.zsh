#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-prebuilt-if-outdated fn-is-os fn-is-arch

typeset version=0.32.0

function parse_kind_version {
  print -- ${${(z)${${(f)1}[1]}}[3]}
}

function install_kind {
  local tmp=$(mktemp -d) os arch
  fn-is-os mac && os=darwin || os=linux
  fn-is-arch arm && arch=arm64 || arch=amd64
  curl -fsSL "https://kind.sigs.k8s.io/dl/v${version}/kind-${os}-${arch}" -o $tmp/kind
  sudo install -m 0755 $tmp/kind /usr/local/bin/kind
  rm -rf $tmp
}

fn-install-prebuilt-if-outdated kind $version install_kind parse_kind_version
##[<] 🤖🤖
