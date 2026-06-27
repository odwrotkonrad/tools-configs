#[what] set shortcuts for accessing directories e.g. ~x_bin -> $XDG_BIN_HOME

hash -d x_bin="${XDG_BIN_HOME}" \
        x_cache="${XDG_CACHE_HOME}" \
        x_config="${XDG_CONFIG_HOME}" \
        x_data="${XDG_DATA_HOME}" \
        x_state="${XDG_STATE_HOME}" \
        x_log="${XDG_STATE_HOME}/log" \
        u_configs="$HOME/projects/configs" \
        u_projects="$HOME/projects"
        u_desktop="$HOME/Desktop" \
        u_capture="$HOME/ScreenCapture"
