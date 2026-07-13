#!/bin/zsh
#[what] ci build deps: go toolchain (https://go.dev/dl/) + prebuilt lefthook, yq, che, render-tpl

emulate -LR zsh
setopt errexit

autoload -Uz fn-install-if-missing fn-install-prebuilt-if-outdated fn-exit-with fn-is-os fn-is-arch fn-log-msg

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
#[what] prebuilt tools: fetch+checksum published binaries instead of go install (no source compile)
#   che renders host + repo templates, render-tpl renders ad-hoc llm prompts
che_version=0.0.45
render_tpl_version=0.0.45
render_repo_group_index_version=0.0.45
lefthook_version=2.1.9
yq_version=4.53.3

#[what] resolve os/arch tokens once, per publisher naming scheme
if { fn-is-os mac }   { che_os=darwin  lh_os=MacOS yq_os=darwin }
if { fn-is-os linux } { che_os=linux   lh_os=Linux yq_os=linux }
if { fn-is-arch arm } { che_arch=arm64 }
if { fn-is-arch x86 } { che_arch=amd64 }
(( ${+che_os} && ${+che_arch} )) || fn-exit-with 1 "unsupported os/arch: $(uname -s)/$(uname -m)"

#[what] lefthook raw-binary asset tokens (Linux_x86_64|Linux_arm64|MacOS_arm64|MacOS_x86_64)
if { fn-is-arch arm } { lh_arch=arm64 } else { lh_arch=x86_64 }

#[what] per-target sha256 (darwin/linux x arm64/amd64); key = os_arch
typeset -A che_sha=(
  darwin_amd64 bb6f5462d119ff49cd66b83affe74ae114cc806e7be1906b4163897a406f10fd
  darwin_arm64 4b37aa2a7aa874812b4eb583ff0ed6c50d4bb4f31d3383eb9fbf22cb843880b2
  linux_amd64  dff2752b2345a63d579cae53adb1e9f8eaede9204f3865b3828b826d04ed65c3
  linux_arm64  76964e95d42a0cf4d9a2f9dc56b5b86abaed9bbfec29db1ec1406ffed46f84fb
)
typeset -A render_tpl_sha=(
  darwin_amd64 84d492b6a775fbb22b8b149d0922dd173b4718a63236ec6c5e08169dd338fe0f
  darwin_arm64 938acd4402ef12d5fb915c2129864170424fcd663782bf1dccf4f07c43e1ca00
  linux_amd64  b709b97cd11ee6142062dd68179dde2c16c62a5d9f3e3ec5c77c9e0624b552eb
  linux_arm64  97dd1cf84cab7ec3635f79bbc8bdba01814468d907a5b1e8e6a4c1610ac04a7a
)
typeset -A render_repo_group_index_sha=(
  darwin_amd64 0266dc918edf11c495f842729ac9186e0cd68a1156c9bd772620de4a894c0782
  darwin_arm64 097dd958e6695022b3c18b7842a88002ddb1b2c5fd9d435af807ef8ae6d76ec4
  linux_amd64  47f6992d1328ee97e0169bec0cea0d94b12b1bbf16cf0bf71c709e99e93fdb6f
  linux_arm64  ab17620e0d56dd40c3f510b4451f9c2909fce3b1369cc5a2ad21dec57a5ee265
)
typeset -A lefthook_sha=(
  Linux_x86_64 0d60b0d350c923963729574f6431171f0277788884ad0c6284fa0160c36e3877
  Linux_arm64  304321997336c450af6b5c0cc641c59141168866fca0b1fc3767e067812600a9
  MacOS_arm64  fd506e05954af2062ce320d59ac1f5bf13fad8d694694a72bc6ef91e8c284e3d
  MacOS_x86_64 0868b9b5b9cd807b0f9e0135fadaff1bd99fa026cccc15cbfd4510f0ee3b5431
)
typeset -A yq_sha=(
  linux_amd64  fa52a4e758c63d38299163fbdd1edfb4c4963247918bf9c1c5d31d84789eded4
  linux_arm64  578648e463a11c1b6db6010cbf41eafed6bee79466fcffa1bb446672cf7945ea
  darwin_amd64 b4ba1ecce3c47f00803f4f964de38394326c7a32eb6540616e04fb2935a0f08d
  darwin_arm64 877de31753a4dd2401aa048937aa9a7fc4d5f6ce858cf31508c5802954297213
)

prefix=/usr/local

#[what] extract a single binary from a checksummed .tar.gz into /usr/local/bin
function install_gitlab_tarball {
  local project=$1 pkg=$2 bin=$3 version=$4 sha=$5
  local archive="${bin}_${version}_${che_os}_${che_arch}.tar.gz"
  local url="https://gitlab.com/api/v4/projects/${project}/packages/generic/${pkg}/${version}/${archive}"
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL -o "$tmp/$archive" "$url"
  echo "$sha  $tmp/$archive" | shasum -a 256 -c - || fn-exit-with 1 "checksum mismatch: $archive"
  tar -xzf "$tmp/$archive" -C "$tmp" "$bin"
  sudo install -m 0755 "$tmp/$bin" "$prefix/bin/$bin"
}

function install_che {
  install_gitlab_tarball 'konradodwrot%2Fgo-modules' che che "$che_version" "${che_sha[${che_os}_${che_arch}]}"
}
function install_render_tpl {
  install_gitlab_tarball 'konradodwrot%2Fgo-modules' che render-tpl "$render_tpl_version" "${render_tpl_sha[${che_os}_${che_arch}]}"
}
function install_render_repo_group_index {
  install_gitlab_tarball 'konradodwrot%2Fgo-modules' che render-repo-group-index "$render_repo_group_index_version" "${render_repo_group_index_sha[${che_os}_${che_arch}]}"
}

#[what] lefthook publishes raw binaries (no tarball) on github
function install_lefthook {
  local asset="lefthook_${lefthook_version}_${lh_os}_${lh_arch}"
  local url="https://github.com/evilmartians/lefthook/releases/download/v${lefthook_version}/${asset}"
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL -o "$tmp/lefthook" "$url"
  echo "${lefthook_sha[${lh_os}_${lh_arch}]}  $tmp/lefthook" | shasum -a 256 -c - || fn-exit-with 1 "checksum mismatch: $asset"
  sudo install -m 0755 "$tmp/lefthook" "$prefix/bin/lefthook"
}

#[what] yq publishes raw binaries on github
function install_yq {
  local asset="yq_${yq_os}_${che_arch}"
  local url="https://github.com/mikefarah/yq/releases/download/v${yq_version}/${asset}"
  local tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" EXIT
  curl -fsSL -o "$tmp/yq" "$url"
  echo "${yq_sha[${yq_os}_${che_arch}]}  $tmp/yq" | shasum -a 256 -c - || fn-exit-with 1 "checksum mismatch: $asset"
  sudo install -m 0755 "$tmp/yq" "$prefix/bin/yq"
}

#[what] version parsers: map raw '--version' output to a bare version
#   che/render-tpl/lefthook -> '<name> version <ver>'; yq -> '...version v<ver>'
function parse_field3   { print -r -- ${${(z)1}[3]} }
function parse_yq       { local v=${${(z)1}[-1]}; print -r -- ${v#v} }

#[why] reinstall on version drift so pin bumps land over a stale binary
fn-install-prebuilt-if-outdated che        "$che_version"        install_che        parse_field3
fn-install-prebuilt-if-outdated render-tpl "$render_tpl_version" install_render_tpl parse_field3
fn-install-prebuilt-if-outdated render-repo-group-index "$render_repo_group_index_version" install_render_repo_group_index parse_field3
fn-install-prebuilt-if-outdated lefthook   "$lefthook_version"   install_lefthook   parse_field3
fn-install-prebuilt-if-outdated yq         "$yq_version"         install_yq         parse_yq
##[<] 🤖🤖
