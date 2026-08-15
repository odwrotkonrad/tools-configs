#[what] zshzle widgets #[where] man zshzle > zle

wd-fn-root-clear-scrollable() {
    #[what] abort current input and clear screen in a way it can be scrolled above to see what inputs was aborted

    if [[ ${BUFFER} ]] {
      print -rn -- "$rt_seq[goto-col-1]${(%%)PS1}# $BUFFER"
    }
    zle reset-prompt
    BUFFER=

    print -n ${(pl:$LINES::\n:)}

    print -n $rt_seq[goto-row-1]
}

wd-fn-root-accept-line() {
    #[what] multiline aware accept-line wrapper
    #[why] native behavior would show PS2 and not use zle multiline editing features otherwise, so multiline editing widgets would not work as expected

    local trail=${(M)BUFFER%'\'}
    if [[ $trail ]] {
      LBUFFER+=$'\n'
      return
    }

    zle .accept-line
}

wd-fn-root-job-foreground() {
    #[what] resume the most recent background job

    if [[ ! ${jobstates} ]] {
      return
    }

    fg
}

wd-fn-root-keystrokes-listen() {
    #[what] listen for raw key sequences
    kitten show-key -m kitty
}

zle-intr() {
    #[what] SIGINT (^C) signal handler

    if { zle } {
      zle wd-fn-root-clear-scrollable
    }
}

##[>] 🤖
typeset -a widgets_custom=(
   wd-fn-root-job-foreground
   wd-fn-root-accept-line
   wd-fn-root-clear-scrollable
   wd-fn-root-keystrokes-listen
)
for widget ( $widgets_custom ) zle -N $widget
##[<] 🤖
