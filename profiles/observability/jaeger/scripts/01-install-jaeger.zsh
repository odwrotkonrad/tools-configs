#!/bin/zsh

emulate -LR zsh

##[>] 🤖🤖
fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-is-virt fn-is-os
fn-is-virt && return 0
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

autoload -Uz fn-install-if-missing

prefix=/usr/local
version=2.18.0
arch=darwin-arm64
archive=jaeger-${version}-${arch}.tar.gz
url=https://github.com/jaegertracing/jaeger/releases/download/v${version}/${archive}
sha256=62778b8d59843a932a595581a0d2d7a2fe0d93c4e970f9a440636c7eb6a7cd24

function install_jaeger {
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  curl -L -o "$tmpdir/$archive" "$url"

  tar -xzf "$tmpdir/$archive" -C "$tmpdir"

  extracted=$tmpdir/jaeger-${version}-${arch}

  #[why] jaeger ships per-file sums, not an archive sum
  echo "$sha256  $extracted/jaeger" | shasum -a 256 -c -

  sudo install -m 0755 "$extracted/jaeger" "$prefix/bin/jaeger"
}

fn-install-if-missing jaeger install_jaeger

##[>] 🤖🤖
autoload -Uz fn-boot-service
fn-boot-service jaeger
##[<] 🤖🤖
