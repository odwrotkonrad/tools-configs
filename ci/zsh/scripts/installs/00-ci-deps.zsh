#!/bin/zsh
#[what] ci build deps bootstrap: che installed/upgraded to the newest released tag via the pages-hosted install.sh (os/arch resolved there), then go via che packages

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
che_version_latest=$(
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors \
    'https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/repository/tags?search=^che/v&per_page=1' |
    sed -n 's|.*"name":"che/v\([^"]*\)".*|\1|p'
)
[[ -n $che_version_latest ]] || { print -u2 'ci-deps: cannot resolve latest che version'; exit 1 }

che_version_installed=''
if { (( ${+commands[che]} )) && che packages --help &> /dev/null } {
  che_version_installed=${${(z)"$(che --version)"}[-1]}
}

if [[ $che_version_installed != $che_version_latest ]] {
  print "ci-deps: installing che ${che_version_latest} (had: ${che_version_installed:-none})"
  curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors https://konradodwrot.gitlab.io/go-modules/install.sh |
    CHE_VERSION=$che_version_latest sh
}
unset CHE_PROFILE
che packages install go
##[<] 🤖🤖
