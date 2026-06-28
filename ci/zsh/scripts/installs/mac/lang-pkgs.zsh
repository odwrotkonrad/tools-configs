#!/bin/zsh
#>[what]
#   install language-level packages: pip (requirements), gem, go, npm.
#   go/npm packages come from the Brewfile's custom directives, filtered by
#   CONFIGS_SPACE section (same markers as brew-packages).
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
###[>] select sections + active Brewfile lines by space
typeset -a sections=( base )
[[ ${CONFIGS_SPACE} == bare-metal ]] && sections+=( bare-metal )

typeset brewfile=/etc/homebrew/Brewfile
typeset -a brewfile_lines=( ${(f)"$(<$brewfile)"} )
typeset -a active_lines
typeset cur=""
for line ( $brewfile_lines ) {
  if [[ $line == '##[>] '* ]] { cur=${line#\#\#[>] }; continue }
  if [[ $line == '##[<]'* ]]  { cur=""; continue }
  (( ${sections[(I)$cur]} )) && active_lines+=$line
}
entries() {
  local l prefix="$1 \""
  for l ( $active_lines ) {
    [[ $l == ${prefix}* ]] || continue
    print -r -- ${${l#$prefix}%%\"*}
  }
}
typeset -a go_pkgs=( ${(f)"$(entries go)"} )
typeset -a npm_pkgs=( ${(f)"$(entries npm)"} )
###[<]

###[>] pip + gem
pip install -r /etc/python/requirements.txt
gem install ruby-lsp
###[<]

###[>] go + npm
for pkg ( $go_pkgs ) go install $pkg@latest
(( $#npm_pkgs )) && npm install -g $npm_pkgs
###[<]
##[<] 🤖🤖
