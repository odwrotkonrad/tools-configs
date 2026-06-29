#!/bin/zsh
#>[what] 🤖🤖
#   Stand in for the `op` CLI when secrets are unavailable (CI): ignore the
#   op:// ref args and emit a placeholder, so *.repo.tpl renders without 1Password.
#   Upstream: gomplate `op` plugin override. Downstream: none.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
print -rn -- "OP_PLACEHOLDER"
##[<] 🤖🤖
