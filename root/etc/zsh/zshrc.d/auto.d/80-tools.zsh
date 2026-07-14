# pyenv #[what] init pyenv: shims on PATH, completions, rehash
eval "$(pyenv init - zsh)"

# fzf #[what] load shell integration: keybindings + completion #[where]https://github.com/junegunn/fzf#setting-up-shell-integration $ man fzf
. <(fzf --zsh)

##[>] 🤖🤖
#[what] minimal fzf history picker: no query line, match-count info bottom-right, no gutter/pointer/marker
export FZF_CTRL_R_OPTS='--layout=reverse --info=right --no-hscroll --pointer= --marker= --gutter=" " --bind=alt-p:up+up+up,alt-n:down+down+down'

wd-fn-root-fzf-history() {
    #[what] fzf history picker, whole typed line as query, one-line trimmed display, full command inserted on accept

    local -a keys=( ${(nOk)history} )
    local k disp sel
    local nl=$'\n' tab=$'\t'

    local input=''
    for k ( $keys ) {
      disp=${history[$k]%%$nl*}
      [[ $disp != ${history[$k]} ]] && disp+=' ...'
      input+="$k$tab$disp$nl"
    }

    sel=$(
      print -rn -- "$input" |
      FZF_DEFAULT_OPTS=$(__fzf_defaults '' "--highlight-line --tiebreak=begin,index ${FZF_CTRL_R_OPTS} --query=${(qqq)LBUFFER}") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) --delimiter=$tab --with-nth=2..
    )

    if [[ -n $sel ]] {
      BUFFER=${history[${sel%%$tab*}]}
      CURSOR=${#BUFFER}
    }

    zle reset-prompt
}
zle -N wd-fn-root-fzf-history
##[<] 🤖🤖
