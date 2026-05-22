# Options are set in GLOBAL_RCS, keeping for the future

typeset -a opts_disabled=()
for opt in ${opts_disabled}; unsetopt ${opt}


typeset -a opts_enabled=()
for opt in ${opts_enabled}; setopt ${opt}


unset opts_disabled opts_enabled
