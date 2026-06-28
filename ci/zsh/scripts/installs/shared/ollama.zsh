#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail

autoload -Uz fn-install-if-missing

models=(
    gemma4:e4b-mlx
)

function install_ollama {
  curl -fsSL https://ollama.com/install.sh | sh
}
fn-install-if-missing ollama install_ollama

# #[what] 🤖🤖 ensure server is up #[why] `ollama pull` needs it; headless has no launchd/app daemon
# if { ! ollama ps >/dev/null 2>&1 } {
#   ollama serve >/dev/null 2>&1 &
#   until ollama ps >/dev/null 2>&1; do sleep 1; done
# }
#
# #[what] always pull models (idempotent)
# for model ( $models ) ollama pull $model
