#!/bin/sh
##[>] 🤖🤖
set -eu

scope=${1:-diff-from-main}

case $scope in
  session)
    echo "session scope: no file list, rewrite prose written this session"
    ;;
  selection)
    echo "selection scope: no file list, rewrite the selected text"
    ;;
  uncommited-changes)
    { git diff HEAD --name-only; git ls-files --others --exclude-standard; } | sort -u
    ;;
  diff-from-main)
    { git diff main --name-only; git ls-files --others --exclude-standard; } | sort -u
    ;;
  all-repo-prose)
    git ls-files '*.md'
    ;;
  *)
    echo "unknown scope: $scope (session|selection|uncommited-changes|diff-from-main|all-repo-prose)" >&2
    exit 1
    ;;
esac
##[<] 🤖🤖
