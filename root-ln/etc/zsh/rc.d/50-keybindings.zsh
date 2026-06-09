#>[⌖]
# root-ln/Users/ko/.config/kitty/kitty.conf                                #[≟] keystroke producer
# root-ln/Users/ko/Library/Application Support/Code/User/keybindings.json  #[≟] keystroke producer
#/[⌖]

#[⌖] https://en.wikipedia.org/wiki/ANSI_escape_code
ESC=$'\u001B'         #[≟] introducer for escape sequences
CSI=$'\u001B['        #[≟] Control Sequence Introducer
DCS=$'\u0090'         #[≟] Device Control String
typeset -A keystrokes=(
    bracketedPaste     "${CSI}200~"

    up                 "${CSI}A"
    down               "${CSI}B"
    right              "${CSI}C"
    left               "${CSI}D"

    cmdUp              "${DCS}U"
    cmdDown            "${DCS}D"
    cmdRight           $'\x05'
    cmdLeft            $'\x01'

    altLeft            "${ESC}b"
    altRight           "${ESC}f"

    backspace          "^H"
    altBackspace       $'\x17'
    cmdBackspace       $'\x15'

    delete             "${CSI}3~"
    altDelete          "${ESC}d"
    cmdDelete          "${DCS}K"

    cmdSemicolon       "${CSI}59;9u"
    ctrlShiftZ         "${DCS}F"

    cmdZ               "${DCS}z"
    cmdShiftZ          "${DCS}Z"
    cmdX               "${DCS}x"

    cr                 $'\r'
    tab                $'\t'

    ctrlV              "^V"
    ctrlX              "^X"
    ctrlZ              "^Z"
    ctrlC              "^C"
    ctrlT              "^T"
    ctrlBackslash      "^\\"
)


#[…] stty [⌖] man stty [≟] set the options for a terminal device interface
#[⌖] stty -a # source of cchars
typeset -a disabled_cchars=(
    start
    stop
)
for cchar in ${disabled_cchars}; stty ${cchar} undef

typeset -A cchars=(
    susp    "$keystrokes[ctrlZ]"            #[≟] Process Suspend (SIGTSTP)
    quit    "$keystrokes[ctrlBackslash]"    #[≟] Process Quit + core dump (SIGQUIT)
    intr    "$keystrokes[ctrlC]"            #[≟] Process Interrupt (SIGINT)
    status  "$keystrokes[ctrlT]"            #[≟] Process Status (SIGINFO)
    lnext   "$keystrokes[ctrlV]"            #[≟] Literal Next, listen next key sequence verbatim
    kill    "$keystrokes[ctrlX]"            #[≟] cut the whole input line
    erase   "$keystrokes[backspace]"        #[≟] backspace, remove last char
    werase  "$keystrokes[altBackspace]"     #[≟] alt+backspace, remove last word
)

for action char in ${(kv)cchars}; stty ${action} ${char}
#[⫶] stty

# [≟] 🤖🤖 SIGINT (^C) signal handler - cancel editing and scroll the prompt to the top without clearing the screen, retaining the terminal contents (including the canceled buffer) and the canceled buffer in history as a comment
TRAPINT() {
    [[ -o zle ]] && {
        [[ -n ${BUFFER} ]] && print -s -- "# ${BUFFER}"
        [[ -n ${BUFFER} ]] && { print -n "${CSI}1G# ${BUFFER}"; zle kill-whole-line }
        print -n ${(pl:$LINES::\n:)}; print -n "${CSI}H"; zle send-break
    }
}


#[…] zshzle
#[⌖] man zshzle > bindkey [≟] zsh doc on bindings

#[≟] non-alnum chars counted as word; empty = strict word boundaries #>[⌖] $ man zshparam
WORDCHARS=""


#[…] 🤖🤖🤖 ctrlV [≟] listen for raw key sequences via kitten show-key
fn-rt-keystrokes-listen() {
    print
    kitten show-key -m kitty
    is-term-kitty && print -n "${CSI}<u"
    zle reset-prompt
}
zle -N fn-rt-keystrokes-listen
#[⫶] ctrlV


#[…] 🤖🤖 ctrlShiftZ [≟] resume the most recent background job (mirror of ^Z suspend)
fn-rt-job-foreground() {
    [[ -n ${jobstates} ]] || return
    [[ -n ${BUFFER} ]] && zle .push-input
    BUFFER="fg"; zle .accept-line
}
zle -N fn-rt-job-foreground
#[⫶] ctrlShiftZ


bindkey -N key_map
bindkey -M key_map -R "^@"-"~" self-insert


typeset -A keystrokes_widgets=(
    "$keystrokes[bracketedPaste]"   .bracketed-paste

    "$keystrokes[up]"               .up-line-or-history
    "$keystrokes[down]"             .down-line-or-history
    "$keystrokes[right]"            .forward-char
    "$keystrokes[left]"             .backward-char

    "$keystrokes[cmdUp]"            .beginning-of-buffer-or-history
    "$keystrokes[cmdDown]"          .end-of-buffer-or-history
    "$keystrokes[cmdRight]"         .vi-end-of-line
    "$keystrokes[cmdLeft]"          .vi-beginning-of-line

    "$keystrokes[altLeft]"          .vi-backward-word
    "$keystrokes[altRight]"         .vi-forward-word

    "$keystrokes[backspace]"        .backward-delete-char
    "$keystrokes[altBackspace]"     .backward-delete-word
    "$keystrokes[cmdBackspace]"     .backward-kill-line

    "$keystrokes[delete]"           .delete-char
    "$keystrokes[altDelete]"        .delete-word
    "$keystrokes[cmdDelete]"        .kill-line

    "$keystrokes[cmdSemicolon]"     .execute-named-cmd
    "$keystrokes[ctrlShiftZ]"       fn-rt-job-foreground

    "$keystrokes[cmdZ]"             .undo
    "$keystrokes[cmdShiftZ]"        .redo
    "$keystrokes[cmdX]"             .kill-buffer

    "$keystrokes[cr]"               .accept-line
    "$keystrokes[tab]"              .expand-or-complete

    "$keystrokes[ctrlV]"            fn-rt-keystrokes-listen
)
for key wid in ${(kv)keystrokes_widgets}; bindkey -M key_map "${key}" "${wid}"

bindkey -A key_map main
#[⫶] zshzle



unset keystrokes_widgets disabled_cchars cchars
