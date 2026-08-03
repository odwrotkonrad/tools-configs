#!/bin/zsh
#>[what]
#   install Homebrew. packages come from ci/zsh/scripts/installs/41-brew-packages.zsh,
#   a fresh shell picking up /opt/homebrew/bin via zshenv.
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
fpath=(${0:a:h}/../root/etc/zsh/zshenv.d/functions $fpath)
##[<] 🤖🤖
autoload -Uz fn-install-if-missing

##[>] 🤖
function install_brew {
  export NONINTERACTIVE=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
fn-install-if-missing brew install_brew
##[<]
