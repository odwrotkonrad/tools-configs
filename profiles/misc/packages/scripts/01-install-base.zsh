#!/bin/zsh
##[>] 🤖🤖
emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install

fn-install bat bats fd ffmpeg gcc htop jq libtool make nmap npm pandoc pcre2 \
  pkgconf pstree readline openssl shellcheck sqlite3 stow tcl tree xz zlib zstd
fn-install ccstatusline claude codex copilot corepack
##[<] 🤖🤖
