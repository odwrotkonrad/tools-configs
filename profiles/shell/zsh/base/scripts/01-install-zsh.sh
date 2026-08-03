#!/bin/sh
##[>] 🤖🤖
set -eu

if command -v zsh >/dev/null 2>&1; then
  echo "zsh: already installed ($(command -v zsh))"
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    echo "zsh: ships with macos, nothing to install"
    ;;
  Linux)
    SUDO=
    [ "$(id -u)" -ne 0 ] && SUDO=sudo
    export DEBIAN_FRONTEND=noninteractive
    $SUDO apt-get update
    $SUDO apt-get install -y zsh
    ;;
  *)
    echo "zsh: unsupported os: $(uname -s)" >&2
    exit 1
    ;;
esac
##[<] 🤖🤖
