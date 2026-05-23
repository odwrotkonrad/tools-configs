# Tools Configuration

# asdf #> https://asdf-vm.com/guide/getting-started.html#_2-configure-asdf

export ASDF_DATA_DIR="${XDG_DATA_HOME}/asdf"
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/.asdfrc"

typeset -U path=(${ASDF_DATA_DIR}/shims ${path})
typeset -U fpath=(${XDG_CONFIG_HOME}/zsh/functions ${ASDF_DATA_DIR}/completions ${fpath})

mkdir -p "${ASDF_DATA_DIR}/completions"
[[ ! -s "${ASDF_DATA_DIR}/completions/_asdf" ]] && asdf completion zsh > "${ASDF_DATA_DIR}/completions/_asdf"

# direnv
eval "$(direnv hook zsh)" #> https://direnv.net/docs/hook.html

# fzf
. <(fzf --zsh) #> https://github.com/junegunn/fzf#setting-up-shell-integration

# claude
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
