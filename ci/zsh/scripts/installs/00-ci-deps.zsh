#!/bin/zsh
#[what] ci build deps: go toolchain (https://go.dev/dl/) + lefthook, gomplate, yq

emulate -LR zsh
setopt errexit

autoload -Uz fn-install-if-missing fn-install-go-mod-if-outdated fn-exit-with fn-is-os fn-is-arch fn-log-msg

version=1.26.4

if { fn-is-os mac && fn-is-arch arm } {
    platform=darwin-arm64
    sha256=b62ad2b6d7d2464f12a5bcad7ff47f19d08325773b5efd21610e445a05a9bf53
}
if { fn-is-os linux && fn-is-arch arm } {
    platform=linux-arm64
    sha256=ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768
}
if { fn-is-os linux && fn-is-arch x86 } {
    platform=linux-amd64
    sha256=1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f
}
(( ${+platform} )) || fn-exit-with 1 "unsupported os/arch: $(uname -s)/$(uname -m)"

prefix=/usr/local
goroot="${prefix}/go"

function install_go {
  local tmp=$(mktemp -d)
  cd $tmp
  local archive="go${version}.${platform}.tar.gz"
  curl -fsSL -O "https://go.dev/dl/${archive}"
  shasum -a 256 -c <<< "${sha256}  ${archive}" || fn-exit-with 1 "checksum mismatch: ${archive}"

  sudo rm -rf "${goroot}"
  sudo tar -xzf "${archive}" -C "${prefix}"

  #[why] mkdir: /usr/local/bin may be absent on a fresh host
  sudo mkdir -p "${prefix}/bin"
  for bin ( go gofmt ) sudo ln -fs "${goroot}/bin/${bin}" "${prefix}/bin/${bin}"
}

fn-install-if-missing go install_go

##[>] 🤖🤖
#[what] go tools: bin -> module@version (3rd-party + own; che renders host + repo templates, render-tpl renders ad-hoc llm prompts)
typeset -A go_tools=(
  lefthook   'github.com/evilmartians/lefthook/v2@v2.1.9'
  yq         'github.com/mikefarah/yq/v4@v4.53.3'
  che        'gitlab.com/konradodwrot/go/che@v0.0.12'
  render-tpl 'gitlab.com/konradodwrot/go/render-files/cmd/render-tpl@v0.0.6'
)

#[why] reinstall on version drift so pin bumps land over a stale binary
for bin module ( ${(kv)go_tools} ) fn-install-go-mod-if-outdated "$bin" "$module"
##[<] 🤖🤖
