#[…] zshzle widgets
#[⌖] man zshzle > zle

# [≟] abort current input and clear screen in a way it can be scrolled above to see what inputs was aborted
wd-rt-clear-scrollable() {
    # 1. print the line as a comment
    if [[ ${BUFFER} ]] {
      print -rn -- "$s_seq[goto-col-1]${(%)PS1}# $BUFFER"
    }
    # 2. reset prompt
    zle reset-prompt
    BUFFER=

    # 3. fill term with new lines
    print -n ${(pl:$LINES::\n:)}

    # 4. move cursor to first row
    print -n $s_seq[goto-row-1]
}
zle -N wd-rt-clear-scrollable

#[≟] multiline aware accept-line wrapper
#[∵] native behavior would show PS2 and not use zle multiline editing features otherwise, so multiline editing widgets would not work as expected
wd-rt-accept-line() {
    local trail=${(M)BUFFER%'\'}
    if [[ $trail ]] {
      LBUFFER+=$'\n'
      return
    }

    zle .accept-line
}
zle -N wd-rt-accept-line
#[⫶] zshzle widgets

#[…] 🤖🤖🤖 ctrlV [≟] listen for raw key sequences via kitten show-key
wd-rt-keystrokes-listen() {
    print
    kitten show-key -m kitty
    is-terminal kitty && print -n "${s_seq[csi]}<u"
    zle reset-prompt
}
zle -N wd-rt-keystrokes-listen
#[⫶] ctrlV


#[…] 🤖🤖 ctrlShiftZ [≟] resume the most recent background job (mirror of ^Z suspend)
wd-rt-job-foreground() {
    [[ -n ${jobstates} ]] || return
    [[ -n ${BUFFER} ]] && zle .push-input
    BUFFER="fg"; zle .accept-line
}
zle -N wd-rt-job-foreground
#[⫶] ctrlShiftZ
