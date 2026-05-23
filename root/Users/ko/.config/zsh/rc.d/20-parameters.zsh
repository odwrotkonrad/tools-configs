# Parameters are set in GLOBAL_RCS

# typeset -U path=(
#     ...
#     ${path}
# )

typeset -U fpath=(
    ${XDG_CONFIG_HOME}/zsh/functions
    ${XDG_STATE_HOME}/zsh/completions
    ${fpath}
)
