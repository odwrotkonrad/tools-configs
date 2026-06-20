#>[where]
# root-ln/Users/ko/.config/kitty/kitty.conf                                #[what] keystroke producer
# root-ln/Users/ko/Library/Application Support/Code/User/keybindings.json  #[what] keystroke producer
#/[where]

typeset -A keystrokes=(
    bracketedPaste     "${rt_seq[csi]}200~"

    up                 "${rt_seq[csi]}A"
    down               "${rt_seq[csi]}B"
    right              "${rt_seq[csi]}C"
    left               "${rt_seq[csi]}D"

    cmdUp              "${rt_seq[dcs]}U"
    cmdDown            "${rt_seq[dcs]}D"
    cmdRight           $'\x05'
    cmdLeft            $'\x01'

    altLeft            "${rt_seq[esc]}b"
    altRight           "${rt_seq[esc]}f"

    backspace          "^H"
    altBackspace       $'\x17'
    cmdBackspace       $'\x15'

    delete             "${rt_seq[csi]}3~"
    altDelete          "${rt_seq[esc]}d"
    cmdDelete          "${rt_seq[dcs]}K"

    ctrlSemicolon      "${rt_seq[csi]}59;5u"
    ctrlShiftZ         "${rt_seq[dcs]}F"

    cmdZ               "${rt_seq[dcs]}z"
    cmdShiftZ          "${rt_seq[dcs]}Z"
    cmdX               "${rt_seq[dcs]}x"

    cr                 $'\r'
    altCr              "${rt_seq[esc]}"$'\n'
    tab                $'\t'

    ctrlV              "^V"
    ctrlX              "^X"
    ctrlZ              "^Z"
    ctrlC              "^C"
    ctrlT              "^T"
    ctrlBackslash      "^\\"
)


##[>] stty [where] man stty [what] set the options for a terminal device interface
#[where] stty -a # source of cchars
typeset -a disabled_cchars=(
    start
    stop
)
for cchar in ${disabled_cchars}; stty ${cchar} undef

typeset -A cchars=(
    susp    "$keystrokes[ctrlZ]"            #[what] Process Suspend (SIGTSTP)
    quit    "$keystrokes[ctrlBackslash]"    #[what] Process Quit + core dump (SIGQUIT)
    intr    "$keystrokes[ctrlC]"            #[what] Process Interrupt (SIGINT)
    status  "$keystrokes[ctrlT]"            #[what] Process Status (SIGINFO)
    lnext   "$keystrokes[ctrlV]"            #[what] Literal Next, listen next key sequence verbatim
    kill    "$keystrokes[ctrlX]"            #[what] cut the whole input line
    erase   "$keystrokes[backspace]"        #[what] backspace, remove last char
    werase  "$keystrokes[altBackspace]"     #[what] alt+backspace, remove last word
)
for action char in ${(kv)cchars}; stty ${action} ${char}
##[<] stty


##[>] zshzle #[where] man zshzle > bindkey
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
    "$keystrokes[ctrlShiftZ]"       wd-fn-rt-job-foreground

    "$keystrokes[cmdZ]"             .undo
    "$keystrokes[cmdShiftZ]"        .redo
    "$keystrokes[cmdX]"             .kill-buffer

    "$keystrokes[cr]"               wd-fn-rt-accept-line
    "$keystrokes[altCr]"            .self-insert-unmeta
    "$keystrokes[tab]"              .expand-or-complete

    "$keystrokes[ctrlV]"            wd-fn-rt-keystrokes-listen
)
for key wid in ${(kv)keystrokes_widgets}; bindkey -M key_map "${key}" "${wid}"

bindkey -A key_map main
##[<] zshzle
