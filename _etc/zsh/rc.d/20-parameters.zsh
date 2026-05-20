#> https://zsh.sourceforge.io/Doc/Release/Parameters.html

typeset -A zsh_params=(
    HISTFILE    "${XDG_STATE_HOME}/zsh/history"
    HISTSIZE    15_000
    PS1         '%# '                             #[I] # for root, % for non root
    PS2         '> '                              #[I] shell waits for input
    PS4         '+ '                              #[I] debugging prompt when XTRACE is set
    SAVEHIST    10_000
)
for k v in "${(@kv)zsh_params}"; typeset "$k=$v" 

unset zsh_params
