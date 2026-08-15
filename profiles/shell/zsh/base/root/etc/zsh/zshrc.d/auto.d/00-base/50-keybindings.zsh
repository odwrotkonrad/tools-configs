#>[where]
# root/_home/.config/kitty/kitty.conf                                #[what] keystroke producer
# profiles/dev/vscode/mac/root/_home/Library/Application Support/Code/User/keybindings.json  #[what] keystroke producer
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

    altUp              "${rt_seq[esc]}p"
    altDown            "${rt_seq[esc]}n"

    backspace          "^H"
    ##[>] 🤖🤖 tmux re-emits BSpace as kbs of tmux-256color (DEL)
    backspaceTmux      "^?"
    ##[<] 🤖🤖
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
    shiftTab           "${rt_seq[csi]}Z"

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
    lnext   "$keystrokes[ctrlV]"            #[what] Literal Next, listen next key sequence verbatim
    kill    "$keystrokes[ctrlX]"            #[what] cut the whole input line
    erase   "$keystrokes[backspace]"        #[what] backspace, remove last char
    werase  "$keystrokes[altBackspace]"     #[what] alt+backspace, remove last word
)
##[>] 🤖🤖
#[why] status/SIGINFO is bsd-only: gnu stty has no such cchar
if { fn-is-os mac } cchars[status]="$keystrokes[ctrlT]" #[what] Process Status (SIGINFO)
if [[ -n $TMUX ]] cchars[erase]="$keystrokes[backspaceTmux]"
##[<] 🤖🤖
for action char in ${(kv)cchars}; stty ${action} ${char}
##[<] stty


##[>] zshzle #[where] man zshzle > bindkey
bindkey -N keymap
bindkey -M keymap -R "^@"-"~" self-insert

typeset -A keystrokes_widgets=(
    "$keystrokes[bracketedPaste]"   .bracketed-paste

    ##[>] 🤖🤖
    "$keystrokes[up]"               wd-fn-root-history-menu
    "$keystrokes[down]"             wd-fn-root-history-menu
    ##[<] 🤖🤖
    "$keystrokes[right]"            .forward-char
    "$keystrokes[left]"             .backward-char

    "$keystrokes[cmdUp]"            .beginning-of-buffer-or-history
    "$keystrokes[cmdDown]"          .end-of-buffer-or-history
    "$keystrokes[cmdRight]"         .vi-end-of-line
    "$keystrokes[cmdLeft]"          .vi-beginning-of-line

    "$keystrokes[altLeft]"          .vi-backward-word
    "$keystrokes[altRight]"         .vi-forward-word

    "$keystrokes[backspace]"        .backward-delete-char
    ##[>] 🤖🤖
    "$keystrokes[backspaceTmux]"    .backward-delete-char
    ##[<] 🤖🤖
    "$keystrokes[altBackspace]"     .backward-delete-word
    "$keystrokes[cmdBackspace]"     .backward-kill-line

    "$keystrokes[delete]"           .delete-char
    "$keystrokes[altDelete]"        .delete-word
    "$keystrokes[cmdDelete]"        .kill-line

    "$keystrokes[ctrlSemicolon]"    execute-named-cmd
    "$keystrokes[ctrlShiftZ]"       wd-fn-root-job-foreground

    "$keystrokes[cmdZ]"             .undo
    "$keystrokes[cmdShiftZ]"        .redo
    "$keystrokes[cmdX]"             .kill-buffer

    "$keystrokes[cr]"               wd-fn-root-accept-line
    "$keystrokes[altCr]"            .self-insert-unmeta
    "$keystrokes[tab]"              complete-word
    "$keystrokes[shiftTab]"         .reverse-menu-complete

    "$keystrokes[ctrlV]"            wd-fn-root-keystrokes-listen
)
for key wid in ${(kv)keystrokes_widgets}; bindkey -M keymap "${key}" "${wid}"

bindkey -A keymap main

##[>] 🤖
bindkey -M menuselect "${rt_seq[esc]}" accept-line
bindkey -M menuselect "$keystrokes[shiftTab]" reverse-menu-complete
##[<] 🤖
##[>] 🤖🤖 alt+arrows mirror the native arrows in the menu: up/down scroll 3 rows, left/right move 1 column
#[why] a user widget bound in menuselect exits menu selection (man zshmodules);
#[why] a bindkey -s macro re-feeds the native arrow key, each move stays in the menu
bindkey -M menuselect -s "$keystrokes[altDown]"  "$keystrokes[down]$keystrokes[down]$keystrokes[down]"
bindkey -M menuselect -s "$keystrokes[altUp]"    "$keystrokes[up]$keystrokes[up]$keystrokes[up]"
bindkey -M menuselect -s "$keystrokes[altRight]" "$keystrokes[right]"
bindkey -M menuselect -s "$keystrokes[altLeft]"  "$keystrokes[left]"
##[<] 🤖🤖
##[<] zshzle
