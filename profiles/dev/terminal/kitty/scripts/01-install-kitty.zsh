#!/bin/zsh
#>[what]
#   install kitty to /Applications, link binaries onto PATH, copy man pages
#/[what]

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-virt fn-is-os
fn-is-virt && return 0
fn-is-os mac || return 0
##[<] 🤖🤖
setopt errexit pipefail

autoload -Uz fn-install-if-missing

prefix=/usr/local
kitty_app_contents=/Applications/kitty.app/Contents

function install_kitty {
  curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
      launch=n  #[what] no launch

  sudo ln -fs "$kitty_app_contents/MacOS/kitten" "$prefix/bin/kitten"
  sudo ln -fs "$kitty_app_contents/MacOS/kitty" "$prefix/bin/kitty"

  #[what] man pages, bin/../share/man
  cd "$kitty_app_contents/Resources/man"

  find . -type d | while read -r man_dir; do
      sudo mkdir -p "$prefix/share/man/$man_dir"
  done

  find . -type f | while read -r man_page; do
      sudo cp -f "$man_page" "$prefix/share/man/$man_page"
  done
}

fn-install-if-missing kitty install_kitty
