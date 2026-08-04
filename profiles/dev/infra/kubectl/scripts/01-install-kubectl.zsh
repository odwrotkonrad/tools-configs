#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-log-msg fn-is-os fn-is-arch is-at-least

typeset version=1.36.0

function install_kubectl {
  local tmp=$(mktemp -d) os arch
  fn-is-os mac && os=darwin || os=linux
  fn-is-arch arm && arch=arm64 || arch=amd64
  curl -fsSL "https://dl.k8s.io/release/v${version}/bin/${os}/${arch}/kubectl" -o $tmp/kubectl
  sudo install -m 0755 $tmp/kubectl /usr/local/bin/kubectl
  rm -rf $tmp
}

#[why] kubectl has no --version flag (fn-install-prebuilt-if-outdated cannot probe it): same skip/never-downgrade logic inlined over `kubectl version --client`
typeset have
if (( $+commands[kubectl] )) {
  have=${${${(f)$(kubectl version --client 2>/dev/null)}[1]##* v}}
  if [[ $have == $version ]] {
    fn-log-msg -t kubectl -- "already installed ($have)"
    return
  }
  if { [[ -n $have ]] && is-at-least $version $have } {
    fn-log-msg -t kubectl -- "keeping $have (newer than pin $version)"
    return
  }
  fn-log-msg -t kubectl -- "reinstalling ${have:-unknown} -> $version"
} else {
  fn-log-msg -t kubectl -- "installing $version"
}

install_kubectl
fn-log-msg -t kubectl -- installed
##[<] 🤖🤖
