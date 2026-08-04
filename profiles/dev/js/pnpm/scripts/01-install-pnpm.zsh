#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-prebuilt-if-outdated fn-is-os fn-is-arch

typeset version=11.0.2

function parse_pnpm_version {
  print -- ${${(f)1}[1]}
}

#[why] the release tarball is a tree (native launcher + dist/ runtime), not a single binary: installed whole under lib, bin is a symlink
function install_pnpm {
  local tmp=$(mktemp -d) os arch
  fn-is-os mac && os=darwin || os=linux
  fn-is-arch arm && arch=arm64 || arch=x64
  curl -fsSL "https://github.com/pnpm/pnpm/releases/download/v${version}/pnpm-${os}-${arch}.tar.gz" | tar -xzf - -C $tmp
  sudo rm -rf /usr/local/lib/pnpm
  sudo mkdir -p /usr/local/lib
  sudo cp -R $tmp /usr/local/lib/pnpm
  sudo ln -fs /usr/local/lib/pnpm/pnpm /usr/local/bin/pnpm
  rm -rf $tmp
}

fn-install-prebuilt-if-outdated pnpm $version install_pnpm parse_pnpm_version
##[<] 🤖🤖
