#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

typeset -a extensions=(
  anthropic.claude-code
  charliermarsh.ruff
  editorconfig.editorconfig
  esbenp.prettier-vscode
  golang.go
  hoovercj.vscode-settings-cycler
  mindaro-dev.file-downloader
  ms-azuretools.vscode-containers
  ms-kubernetes-tools.vscode-kubernetes-tools
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-python-envs
  ms-vscode-remote.remote-containers
  openai.chatgpt
  redhat.vscode-yaml
  tamasfe.even-better-toml
  yzhang.markdown-all-in-one
)

typeset -a installed=( ${(f)"$(code --list-extensions)"} )
for ext ( $extensions ) {
  (( ${installed[(Ie)$ext]} )) || code --install-extension $ext
}
##[<] 🤖🤖
