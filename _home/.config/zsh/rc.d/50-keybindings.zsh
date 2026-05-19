# Z Line Editor

#> param definition in - manual: ZSHPARAM(1) 
WORDCHARS=""


bindkey -N key_map
bindkey -M key_map -R "^@"-"~" self-insert


#> https://en.wikipedia.org/wiki/ANSI_escape_code

ESC=$'\u001B'         #[I] introducer for escape sequences; also the Alt/Meta prefix
CSI=$'\u001B['        #[I] Control Sequence Introducer; prefix for standard key sequences
DCS=$'\u0090'         #[I] Device Control String; used here as a prefix used for self-defined non canonical keystrokes
BS="${terminfo[kbs]}" #[?] Backspace byte; varies by terminal - ^H (BS, 0x08) on some, ^? (DEL, 0x7F)

typeset -A keystrokes=(
    bracketedPaste     "${CSI}200~"

    up                 "${CSI}A"
    down               "${CSI}B"
    right              "${CSI}C"
    left               "${CSI}D"

    cmdUp              "${CSI}1;9A"
    cmdDown            "${CSI}1;9B"
    cmdRight           "${CSI}1;9C"
    cmdLeft            "${CSI}1;9D"

    altLeft            "${CSI}1;3D"
    altRight           "${CSI}1;3C"

    backspace          "${BS}"
    cmdBackspace       "${DCS}${BS}"
    altBackspace       "${ESC}${BS}"

    delete             "${CSI}3~"
    altDelete          "${CSI}3;3~"
    cmdDelete          "${CSI}3;9~"

    cmdZ               "${DCS}z"
    cmdShiftZ          "${DCS}Z"
    cmdX               "${DCS}x"

    cr                 $'\r'
    tab                $'\t'
)

typeset -A keystrokes_widgets=(
    "$keystrokes[bracketedPaste]"   bracketed-paste

    "$keystrokes[up]"               up-line-or-history
    "$keystrokes[down]"             down-line-or-history
    "$keystrokes[right]"            forward-char
    "$keystrokes[left]"             backward-char

    "$keystrokes[cmdUp]"            beginning-of-buffer-or-history
    "$keystrokes[cmdDown]"          end-of-buffer-or-history
    "$keystrokes[cmdRight]"         vi-end-of-line
    "$keystrokes[cmdLeft]"          vi-beginning-of-line

    "$keystrokes[altLeft]"          vi-backward-word
    "$keystrokes[altRight]"         vi-forward-word

    "$keystrokes[backspace]"        backward-delete-char
    "$keystrokes[cmdBackspace]"     backward-kill-line
    "$keystrokes[altBackspace]"     backward-delete-word

    "$keystrokes[delete]"           delete-char
    "$keystrokes[altDelete]"        delete-word
    "$keystrokes[cmdDelete]"        kill-line

    "$keystrokes[cmdZ]"             undo
    "$keystrokes[cmdShiftZ]"        redo
    "$keystrokes[cmdX]"             kill-buffer

    "$keystrokes[cr]"               accept-line
    "$keystrokes[tab]"              expand-or-complete
)
for key wid in ${(kv)keystrokes_widgets}; bindkey -M key_map "${key}" "${wid}" 

bindkey -A key_map main


# STTY 

#> stty -a # source of cchars 
typeset -a disabled_cchars=(
    start
    stop
)
for cchar in ${disabled_cchars}; stty ${cchar} undef

typeset -A cchars=(
    susp    '^Z'        # Process Suspend (SIGTSTP)
    quit    '^\\'       # Process Quit + core dump (SIGQUIT)
    intr    '^C'        # Process Interrupt (SIGINT)
    status  '^T'        # Process Status (SIGINFO)
)

for action char in ${(kv)cchars}; stty ${action} ${char}


unset keystrokes_widgets disabled_cchars cchars
