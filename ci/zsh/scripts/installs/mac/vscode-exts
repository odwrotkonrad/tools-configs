#!/bin/zsh
#>[what]
#   install vscode extensions (host-only). reads `vscode "..."` directives from
#   the Brewfile's bare-metal section. #[why] needs the code cli (from the editor).
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
###[>] read vscode entries from the bare-metal section only
typeset brewfile=/etc/homebrew/Brewfile
typeset -a brewfile_lines=( ${(f)"$(<$brewfile)"} )
typeset -a active_lines
typeset cur=""
for line ( $brewfile_lines ) {
  if [[ $line == '##[>] '* ]] { cur=${line#\#\#[>] }; continue }
  if [[ $line == '##[<]'* ]]  { cur=""; continue }
  [[ $cur == bare-metal ]] && active_lines+=$line
}
typeset -a vscode_exts
for l ( $active_lines ) {
  [[ $l == 'vscode "'* ]] || continue
  vscode_exts+=${${l#vscode \"}%%\"*}
}
###[<]

for ext ( $vscode_exts ) code --install-extension $ext --force
##[<] 🤖🤖
