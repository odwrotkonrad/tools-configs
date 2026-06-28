#!/bin/zsh

emulate -LR zsh
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

  #[what] 1. download release archive
  curl -L -o "$tmpdir/$archive" "$url"

  #[what] 2. verify checksum
  echo "$sha256  $tmpdir/$archive" | shasum -a 256 -c -

  #[what] 3. extract archive
  tar -xzf "$tmpdir/$archive" -C "$tmpdir"

  extracted=$tmpdir/prometheus-${version}.${arch}

  #[what] 4. install binaries to standard PATH location
  sudo install -m 0755 "$extracted/prometheus" "$prefix/bin/prometheus"
  sudo install -m 0755 "$extracted/promtool" "$prefix/bin/promtool"
}

fn-install-if-missing prometheus install_prometheus
