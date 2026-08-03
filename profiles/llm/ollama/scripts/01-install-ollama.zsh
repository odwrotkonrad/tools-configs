#!/bin/zsh

emulate -LR zsh

##[>] 🤖🤖
autoload -Uz fn-is-virt
fn-is-virt && return 0
##[<] 🤖🤖
setopt errexit pipefail

autoload -Uz fn-install-if-missing

models=(
    gemma4:e4b-mlx
)

function install_ollama {
  curl -fsSL https://ollama.com/install.sh | sh
}
fn-install-if-missing ollama install_ollama

# 🤖🤖 #[why] `ollama pull` needs server up, headless has no launchd/app daemon
# if { ! ollama ps >/dev/null 2>&1 } {
#   ollama serve >/dev/null 2>&1 &
#   until ollama ps >/dev/null 2>&1; do sleep 1; done
# }
#
# #[what] pull models (idempotent)
# for model ( $models ) ollama pull $model
