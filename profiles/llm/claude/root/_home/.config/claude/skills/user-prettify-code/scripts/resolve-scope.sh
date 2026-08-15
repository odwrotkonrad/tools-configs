#!/bin/sh
##[>] 🤖🤖
set -eu

scope=${1:-diff-from-main}

case $scope in
  all-repo)
    git ls-files
    ;;
  uncommited-changes)
    { git diff HEAD --name-only; git ls-files --others --exclude-standard; } | sort -u
    ;;
  diff-from-main)
    { git diff main --name-only; git ls-files --others --exclude-standard; } | sort -u
    ;;
  *)
    if [ -e "$scope" ]; then
      git ls-files "$scope"
    else
      echo "unknown scope: $scope (all-repo|uncommited-changes|diff-from-main|<path>)" >&2
      exit 1
    fi
    ;;
esac
##[<] 🤖🤖
