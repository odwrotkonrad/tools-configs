#!/bin/sh
##[>] 🤖🤖
set -eu

if command -v curl >/dev/null 2>&1; then
  echo "curl: already installed ($(command -v curl))"
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    echo "curl: ships with macos, nothing to install"
    ;;
  Linux)
    SUDO=
    [ "$(id -u)" -ne 0 ] && SUDO=sudo
    export DEBIAN_FRONTEND=noninteractive
    $SUDO apt-get update
    $SUDO apt-get install -y curl ca-certificates
    ;;
  *)
    echo "curl: unsupported os: $(uname -s)" >&2
    exit 1
    ;;
esac
##[<] 🤖🤖
