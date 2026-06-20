#[what] zshzle widgets #[where] man zshzle > zle

wd-fn-rt-clear-scrollable() {
    #[what] abort current input and clear screen in a way it can be scrolled above to see what inputs was aborted

    # 1. print current input as a comment
    if [[ ${BUFFER} ]] {
      print -rn -- "$rt_seq[goto-col-1]${(%)PS1}# $BUFFER"
    }
    # 2. reset input
    zle reset-prompt
    BUFFER=

    # 3. fill terminal with new lines
    print -n ${(pl:$LINES::\n:)}

    # 4. move empty prompt line to first terminal row
    print -n $rt_seq[goto-row-1]
}

wd-fn-rt-accept-line() {
    #[what] multiline aware accept-line wrapper
    #[why] native behavior would show PS2 and not use zle multiline editing features otherwise, so multiline editing widgets would not work as expected

    local trail=${(M)BUFFER%'\'}
    if [[ $trail ]] {
      LBUFFER+=$'\n'
      return
    }

    zle .accept-line
}

wd-fn-rt-job-foreground() {
    #[what] resume the most recent background job

    if [[ ! ${jobstates} ]] {
      return
    }

    fg
}

wd-fn-rt-keystrokes-listen() {
    #[what] listen for raw key sequences
    kitten show-key -m kitty
}

zle-intr() {
    #[what] SIGINT (^C) signal handler

    ##[>] 🤖
    if { zle } {
      zle wd-fn-rt-clear-scrollable
    }
    ##[<] 🤖
}


typeset -a wd_fn_rt=(
   wd-fn-rt-job-foreground
   wd-fn-rt-accept-line
   wd-fn-rt-clear-scrollable
   wd-fn-rt-keystrokes-listen
)
for widget ( $wd_fn_rt ) zle -N $widget
