
typeset -a dirs=(
    "${HOME}/ScreenCapture"
    "${XDG_CACHE_HOME}/homebrew"
    "${XDG_STATE_HOME}/asdf"
    "${XDG_STATE_HOME}/homebrew"
    "${XDG_STATE_HOME}/log"
    "${XDG_STATE_HOME}/vim/undo"
    "${XDG_STATE_HOME}/zsh"                              # zsh history
    "${XDG_STATE_HOME}/zsh/completions"                  # generated completions
)
mkdir -p ${(v)xdg_default_locations} ${dirs}             # create dirs if non existing
unset dirs

hash -d x_bin="${XDG_BIN_HOME}" \
        x_cache="${XDG_CACHE_HOME}" \
        x_config="${XDG_CONFIG_HOME}" \
        x_data="${XDG_DATA_HOME}" \
        x_state="${XDG_STATE_HOME}" \
        x_log="${XDG_STATE_HOME}/log" \

hash -d u_configs="$HOME/projects/configs" \
        u_projects="$HOME/projects"
        u_desktop="$HOME/Desktop" \
        u_capture="$HOME/ScreenCapture"     # adds dirs to cd with ~name
