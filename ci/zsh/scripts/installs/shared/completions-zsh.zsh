#!/bin/zsh
#>[what]
#   generate zsh completion files
#/[what]

emulate -LR zsh
setopt errexit
umask 002

rg --generate=complete-zsh | sudo tee /etc/zsh/zshrc.d/completions/_rg >/dev/null
asdf completion zsh | sudo tee /etc/zsh/zshrc.d/completions/_asdf >/dev/null
codex completion zsh | sudo tee /etc/zsh/zshrc.d/completions/_codex >/dev/null
