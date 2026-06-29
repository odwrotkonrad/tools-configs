#!/bin/zsh
#>[what]
#   install CLIs that ship their own native curl-pipe installers: codex, claude
#/[what]

emulate -LR zsh
setopt errexit pipefail

autoload -Uz fn-install-if-missing


function install_codex {
  curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR="${HOME}/.local/bin" sh
}
fn-install-if-missing codex install_codex

##[>] 🤖
function install_claude {
  curl -fsSL https://claude.ai/install.sh | bash
}
fn-install-if-missing claude install_claude
##[<] 🤖
