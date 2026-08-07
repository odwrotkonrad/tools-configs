#!/bin/zsh
##[>] 🤖🤖
emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install

fn-install bat bats che fd ffmpeg gcc htop jq libtool make nmap npm pandoc pcre2 \
  pkgconf procs pstree readline openssl shellcheck showkey sqlite3 stow tcl tree \
  unzip watch xz yq zlib zstd
fn-install ccstatusline claude codex copilot corepack
##[<] 🤖🤖
