#!/bin/zsh
#[what] ci build deps: che (mac: brew tap formula, linux: pages-hosted install.sh), then go + lefthook + yq via che packages

emulate -LR zsh
setopt errexit

autoload -Uz fn-install-if-missing fn-is-os

##[>] 🤖🤖
function install_che {
  if { fn-is-os mac } {
    brew trust --tap konradodwrot/tap
    brew install konradodwrot/tap/che
    return
  }
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors https://konradodwrot.gitlab.io/go-modules/install.sh | sh
}

fn-install-if-missing che install_che
che packages install go
##[<] 🤖🤖
