#!/bin/zsh
#[what] ci build deps: go toolchain (https://go.dev/dl/) + lefthook, gomplate, yq

emulate -LR zsh
setopt errexit

autoload -Uz fn-install-if-missing fn-exit-with fn-is-os fn-is-arch fn-log-msg

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
#[why] install into GOPATH/bin (no sudo); run-target wrapper has it on PATH
function go_install { PATH="${goroot}/bin:${PATH}" go install "$1" }

#[what] 3rd-party go tools: bin -> module@version
typeset -A third_party_tools=(
  lefthook  'github.com/evilmartians/lefthook/v2@v2.1.9'
  gomplate  'github.com/hairyhenderson/gomplate/v5/cmd/gomplate@v5.1.0'
  yq        'github.com/mikefarah/yq/v4@v4.53.3'
)

#[what] own published go tools needed by repo-ci: render-* at template render, che at dry-run sync
typeset -A own_tools=(
  che                  'gitlab.com/konradodwrot/go/che@v0.0.4'
  render-makefile-doc  'gitlab.com/konradodwrot/go/render-files/cmd/render-makefile-doc@v0.0.2'
  render-dirs-tree     'gitlab.com/konradodwrot/go/render-files/cmd/render-dirs-tree@v0.0.2'
)

for bin module ( ${(kv)third_party_tools} ${(kv)own_tools} ) {
  if (( $+commands[$bin] )) {
    fn-log-msg -t "$bin" -- already installed
    continue
  }
  fn-log-msg -t "$bin" -- installing
  go_install "$module"
  fn-log-msg -t "$bin" -- installed
}
##[<] 🤖🤖
