#[…] named dirs
#>[≟]
# hash - zsh builtin - modify the contents of the cmd and dir hash tables
#   -d - target named directory hash table rather than command hash table
# dir hash table is used to expand `~` e.g. ~x_bin -> $XDG_BIN_HOME
#/[≟]
hash -d x_bin="${XDG_BIN_HOME}" \
        x_cache="${XDG_CACHE_HOME}" \
        x_config="${XDG_CONFIG_HOME}" \
        x_data="${XDG_DATA_HOME}" \
        x_state="${XDG_STATE_HOME}" \
        x_log="${XDG_STATE_HOME}/log" \

hash -d u_configs="$HOME/projects/configs" \
        u_projects="$HOME/projects"
        u_desktop="$HOME/Desktop" \
        u_capture="$HOME/ScreenCapture"
#[⫶] named dirs
