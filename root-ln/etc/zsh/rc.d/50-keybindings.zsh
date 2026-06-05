#>[⌖]
# root-ln/Users/ko/.config/kitty/kitty.conf                                #[≟] keystroke producer
# root-ln/Users/ko/Library/Application Support/Code/User/keybindings.json  #[≟] keystroke producer
#/[⌖]

#[…] zshzle
#[⌖] man zshzle > bindkey [≟] zsh doc on bindings

#[≟] non-alnum chars counted as word; empty = strict word boundaries #>[⌖] $ man zshparam
WORDCHARS=""


bindkey -N key_map
bindkey -M key_map -R "^@"-"~" self-insert


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

    backspace          $'\x7f'
    altBackspace       $'\x17'
    cmdBackspace       $'\x15'
    ctrlBackspace      $'\x08'

    delete             "${CSI}3~"
    altDelete          "${ESC}d"
    cmdDelete          "${DCS}K"

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
    "$keystrokes[altBackspace]"     backward-delete-word
    "$keystrokes[cmdBackspace]"     backward-kill-line
    "$keystrokes[ctrlBackspace]"    backward-kill-line

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
#[⫶]

#[…] stty [⌖] man stty [≟] set the options for a terminal device interface

#[⌖] stty -a # source of cchars
typeset -a disabled_cchars=(
    start
    stop
)
for cchar in ${disabled_cchars}; stty ${cchar} undef

typeset -A cchars=(
    susp    '^Z'        #[≟] Process Suspend (SIGTSTP)
    quit    '^\\'       #[≟] Process Quit + core dump (SIGQUIT)
    intr    '^C'        #[≟] Process Interrupt (SIGINT)
    status  '^T'        #[≟] Process Status (SIGINFO)
)

for action char in ${(kv)cchars}; stty ${action} ${char}
#[⫶]

# [≟] SIGINT (^C) signal handler, clear the screen and reset prompt input, only when zle is active
TRAPINT() {
    [[ -o zle ]] && clear
    return $(( 128 + $1 ))
}



unset keystrokes_widgets disabled_cchars cchars
