#!/bin/sh
##[>] 🤖🤖
set -eu

lang=${1:-}

[ -z "$lang" ] && exit 0

principles_path="$HOME/.config/claude/rules/code/$lang/principles.md"

if [ -f "$principles_path" ]; then
  cat "$principles_path"
else
  echo "unknown lang: $lang (no $principles_path)" >&2
  exit 1
fi
##[<] 🤖🤖
