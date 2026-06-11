#>[⌖]
# root-ln/Users/ko/.config/kitty/kitty.conf                                #[≟] keystroke producer
# root-ln/Users/ko/Library/Application Support/Code/User/keybindings.json  #[≟] keystroke producer
#/[⌖]

typeset -A keystrokes=(
    bracketedPaste     "${s_seq[csi]}200~"

    up                 "${s_seq[csi]}A"
    down               "${s_seq[csi]}B"
    right              "${s_seq[csi]}C"
    left               "${s_seq[csi]}D"

    cmdUp              "${s_seq[dcs]}U"
    cmdDown            "${s_seq[dcs]}D"
    cmdRight           $'\x05'
    cmdLeft            $'\x01'

    altLeft            "${s_seq[esc]}b"
    altRight           "${s_seq[esc]}f"

    backspace          "^H"
    altBackspace       $'\x17'
    cmdBackspace       $'\x15'

    delete             "${s_seq[csi]}3~"
    altDelete          "${s_seq[esc]}d"
    cmdDelete          "${s_seq[dcs]}K"

    ctrlSemicolon      "${s_seq[csi]}59;5u"
    ctrlShiftZ         "${s_seq[dcs]}F"

    cmdZ               "${s_seq[dcs]}z"
    cmdShiftZ          "${s_seq[dcs]}Z"
    cmdX               "${s_seq[dcs]}x"

    cr                 $'\r'
    altCr              "${s_seq[esc]}"$'\n'
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


#[…] zshzle
#[⌖] man zshzle > bindkey [≟] zsh doc on bindings

#[≟] non-alnum chars counted as word; empty = strict word boundaries #>[⌖] $ man zshparam
WORDCHARS=""


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

    "$keystrokes[ctrlSemicolon]"    execute-named-cmd
    "$keystrokes[ctrlShiftZ]"       wd-rt-job-foreground

    "$keystrokes[cmdZ]"             .undo
    "$keystrokes[cmdShiftZ]"        .redo
    "$keystrokes[cmdX]"             .kill-buffer

    "$keystrokes[cr]"               wd-rt-accept-line
    "$keystrokes[altCr]"            .self-insert-unmeta
    "$keystrokes[tab]"              .expand-or-complete

    "$keystrokes[ctrlV]"            wd-rt-keystrokes-listen
)
for key wid in ${(kv)keystrokes_widgets}; bindkey -M key_map "${key}" "${wid}"

bindkey -A key_map main
#[⫶] zshzle


# [≟] SIGINT (^C) signal handler — delegate to the clear-scrollable widget when zle is active
TRAPINT() {
    [[ -o zle ]] && zle wd-rt-clear-scrollable
}


unset keystrokes_widgets disabled_cchars cchars
