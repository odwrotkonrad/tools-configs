#!/bin/zsh
##[>] 🤖🤖
emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-prebuilt-if-outdated fn-exit-with fn-is-os fn-is-arch

rg_version=14.1.1

if { fn-is-os mac   && fn-is-arch arm } { rg_target=aarch64-apple-darwin }
if { fn-is-os mac   && fn-is-arch x86 } { rg_target=x86_64-apple-darwin }
if { fn-is-os linux && fn-is-arch arm } { rg_target=aarch64-unknown-linux-gnu }
if { fn-is-os linux && fn-is-arch x86 } { rg_target=x86_64-unknown-linux-musl }
(( ${+rg_target} )) || fn-exit-with 1 "unsupported os/arch: $(uname -s)/$(uname -m)"

typeset -A rg_sha=(
  aarch64-apple-darwin      24ad76777745fbff131c8fbc466742b011f925bfa4fffa2ded6def23b5b937be
  x86_64-apple-darwin       fc87e78f7cb3fea12d69072e7ef3b21509754717b746368fd40d88963630e2b3
  aarch64-unknown-linux-gnu c827481c4ff4ea10c9dc7a4022c8de5db34a5737cb74484d62eb94a95841ab2f
  x86_64-unknown-linux-musl 4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e
)

prefix=/usr/local
SUDO=
(( EUID != 0 )) && SUDO=sudo

function install_rg {
  local asset="ripgrep-${rg_version}-${rg_target}.tar.gz"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/${rg_version}/${asset}"
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -o "$tmp/$asset" "$url"
  echo "${rg_sha[$rg_target]}  $tmp/$asset" | shasum -a 256 -c - || fn-exit-with 1 "checksum mismatch: $asset"
  tar -xzf "$tmp/$asset" -C "$tmp" --strip-components=1 "${asset%.tar.gz}/rg"
  [[ -d ${prefix}/bin ]] || $SUDO mkdir -p "${prefix}/bin"
  $SUDO install -m 0755 "$tmp/rg" "${prefix}/bin/rg"
}

function parse_rg_version { print -r -- ${${(z)${(f)1}[1]}[2]} }

fn-install-prebuilt-if-outdated rg "$rg_version" install_rg parse_rg_version
##[<] 🤖🤖
