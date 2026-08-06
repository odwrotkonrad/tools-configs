#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install-prebuilt-if-outdated fn-is-os fn-is-arch

typeset version=1.15.0

function parse_terraform_version {
  print -- ${${${(f)1}[1]}#Terraform v}
}

function install_terraform {
  local tmp=$(mktemp -d) os arch
  fn-is-os mac && os=darwin || os=linux
  fn-is-arch arm && arch=arm64 || arch=amd64
  curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSL "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip" -o $tmp/terraform.zip
  unzip -oq $tmp/terraform.zip -d $tmp
  sudo install -m 0755 $tmp/terraform /usr/local/bin/terraform
  rm -rf $tmp
}

fn-install-prebuilt-if-outdated terraform $version install_terraform parse_terraform_version
##[<] 🤖🤖
