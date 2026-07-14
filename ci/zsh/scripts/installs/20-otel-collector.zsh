#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail

autoload -Uz fn-install-if-missing

prefix=/usr/local
version=0.153.0
arch=darwin_arm64
archive=otelcol_${version}_${arch}.tar.gz
url=https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${version}/${archive}
sha256=9585e6bf82aa36ae9dcdaaf2f8546c726e152c4d0374c6830dd488a3ba6d2dc2

function install_otelcol {
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  curl -L -o "$tmpdir/$archive" "$url"

  echo "$sha256  $tmpdir/$archive" | shasum -a 256 -c -

  tar -xzf "$tmpdir/$archive" -C "$tmpdir"

  sudo install -m 0755 "$tmpdir/otelcol" "$prefix/bin/otelcol"
}

fn-install-if-missing otelcol install_otelcol

##[>] 🤖🤖
autoload -Uz fn-is-os fn-is-virt fn-boot-service
if { ! fn-is-virt && fn-is-os mac } fn-boot-service otelcol
##[<] 🤖🤖
