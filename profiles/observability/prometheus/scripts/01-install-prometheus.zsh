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
version=3.5.3
arch=darwin-amd64
archive=prometheus-${version}.${arch}.tar.gz
url=https://github.com/prometheus/prometheus/releases/download/v${version}/${archive}
sha256=408eec9f1138ad5d30509038b2e8ae798ed2910e7faaa0e7f61ca22db222aaf5

function install_prometheus {
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  curl -L --connect-timeout 30 --retry 5 --retry-delay 2 --retry-all-errors -o "$tmpdir/$archive" "$url"

  echo "$sha256  $tmpdir/$archive" | shasum -a 256 -c -

  tar -xzf "$tmpdir/$archive" -C "$tmpdir"

  extracted=$tmpdir/prometheus-${version}.${arch}

  sudo install -m 0755 "$extracted/prometheus" "$prefix/bin/prometheus"
  sudo install -m 0755 "$extracted/promtool" "$prefix/bin/promtool"
}

fn-install-if-missing prometheus install_prometheus

##[>] 🤖🤖
autoload -Uz fn-boot-service
fn-boot-service prometheus
##[<] 🤖🤖
