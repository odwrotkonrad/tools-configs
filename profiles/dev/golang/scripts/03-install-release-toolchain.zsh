#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-if-missing fn-is-os fn-is-arch

typeset zig_version=0.16.0
typeset zig_arch=x86_64 gr_arch=x86_64
if { fn-is-arch arm } { zig_arch=aarch64; gr_arch=arm64 }
typeset -a sudo_cmd=( )
(( UID )) && sudo_cmd=( sudo )

function install_goreleaser {
  if { fn-is-os mac } { brew install goreleaser; return }
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -o $tmp/goreleaser.tar.gz "https://github.com/goreleaser/goreleaser/releases/latest/download/goreleaser_Linux_${gr_arch}.tar.gz"
  tar -xz -C $tmp -f $tmp/goreleaser.tar.gz goreleaser
  $sudo_cmd install -m 0755 $tmp/goreleaser /usr/local/bin/goreleaser
}
fn-install-if-missing goreleaser install_goreleaser

function install_zig {
  if { fn-is-os mac } { brew install zig; return }
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -o $tmp/zig.tar.xz "https://ziglang.org/download/${zig_version}/zig-${zig_arch}-linux-${zig_version}.tar.xz"
  $sudo_cmd tar -xJ -C /usr/local -f $tmp/zig.tar.xz
  $sudo_cmd ln -sf "/usr/local/zig-${zig_arch}-linux-${zig_version}/zig" /usr/local/bin/zig
}
fn-install-if-missing zig install_zig
##[<] 🤖🤖
