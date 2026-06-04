#[≟] 2nd file sourced after /etc/zshenv

#[≟] load claude-specific config file if this is its shell
if [[ "${CLAUDECODE}" == "1" ]]; then
    . "${ZDOTDIR}/.zclaude"
fi
