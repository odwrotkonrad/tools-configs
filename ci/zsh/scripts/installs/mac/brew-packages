#!/bin/zsh
#>[what]
#   install Brewfile entries by type: taps, casks, formulae.
#   parses /etc/homebrew/Brewfile by section-comment markers, reading only the
#   sections valid for CONFIGS_SPACE (exported by che install-tools):
#   always 'base'; plus 'bare-metal' when CONFIGS_SPACE=bare-metal.
#   #[why] brew bundle can't order by type, can't section, ignores go/npm/vscode.
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
###[>] select sections by space #[why] VM (virt) gets base only; host adds bare-metal
typeset -a sections=( base )
[[ ${CONFIGS_SPACE} == bare-metal ]] && sections+=( bare-metal )
###[<]

###[>] read Brewfile, keep only lines inside a selected section #[why] zsh-native, no rg yet
typeset brewfile=/etc/homebrew/Brewfile
typeset -a brewfile_lines=( ${(f)"$(<$brewfile)"} )
typeset -a active_lines
typeset cur=""
for line ( $brewfile_lines ) {
  if [[ $line == '##[>] '* ]] { cur=${line#\#\#[>] }; continue }
  if [[ $line == '##[<]'* ]]  { cur=""; continue }
  (( ${sections[(I)$cur]} )) && active_lines+=$line
}
###[<]

###[>] entries by type from the active lines
entries() {
  local l prefix="$1 \""
  for l ( $active_lines ) {
    [[ $l == ${prefix}* ]] || continue
    print -r -- ${${l#$prefix}%%\"*}  #[what] strip `<type> "` prefix + trailing quote (+opts)
  }
}
typeset -a taps=( ${(f)"$(entries tap)"} )
typeset -a casks=( ${(f)"$(entries cask)"} )
typeset -a formulae=( ${(f)"$(entries brew)"} )
###[<]

###[>] taps, then casks, then formulae
export NONINTERACTIVE=1
export HOMEBREW_NO_ASK=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
for t ( $taps ) brew tap $t
(( $#casks )) && brew install --cask $casks
(( $#formulae )) && brew install $formulae
###[<]
##[<] 🤖🤖
