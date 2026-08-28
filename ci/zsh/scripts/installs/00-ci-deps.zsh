#!/bin/zsh
#[what] ci build deps bootstrap: che via the pages-hosted che-install.sh (pinned to GO_MODULES_CHE_REF when set, else latest, a newer build kept, a local dev build never touched), then go via che packages

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
che_version=${${GO_MODULES_CHE_REF:-latest}#che/v}
che_version_installed=${${(z)"$(che --version 2> /dev/null || true)"}[3]}
if [[ $che_version_installed == dev ]] {
  print 'ci-deps: che is a local dev build, keeping it'
} else {
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 https://konradodwrot.gitlab.io/go-modules/che-install.sh |
    INSTALL_CHE_VERSION=$che_version INSTALL_CHE_SKIP_IF_PRESENT_IS_NEWER=1 sh
}
unset CHE_PROFILE
che packages install go
##[<] 🤖🤖
