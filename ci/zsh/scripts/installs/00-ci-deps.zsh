#!/bin/zsh
#[what] ci build deps bootstrap: che via the pages-hosted install.sh (os/arch resolved there), then go via che packages

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
if { (( ! ${+commands[che]} )) || ! che packages --help &> /dev/null } {
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors https://konradodwrot.gitlab.io/go-modules/install.sh | sh
}
unset CHE_PROFILE
che packages install go
##[<] 🤖🤖
