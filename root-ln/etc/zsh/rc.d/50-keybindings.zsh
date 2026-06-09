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

# [≟] 🤖🤖 SIGINT (^C) signal handler - cancel editing, scroll prompt to the top without clearing the screen, retaining history and the canceled buffer
TRAPINT() {
    [[ -o zle ]] && { print -n ${(pl:$LINES::\n:)}; print -n "${CSI}H"; zle send-break }
}


#[…] zshzle
#[⌖] man zshzle > bindkey [≟] zsh doc on bindings

#[≟] non-alnum chars counted as word; empty = strict word boundaries #>[⌖] $ man zshparam
WORDCHARS=""


#[…] 🤖🤖 ctrlV [≟] listen for raw key sequences via kitten show-key
fn-rt-keystrokes-listen() {
    print
    kitten show-key -m kitty
    zle reset-prompt
}
zle -N fn-rt-keystrokes-listen
#[⫶] ctrlV


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
