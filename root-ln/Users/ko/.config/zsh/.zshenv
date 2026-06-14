#[≟] 2nd file sourced after /etc/zshenv

#[…] 🤖🤖 user env
typeset -A env_vars=(
    AWS_CONFIG_FILE         "${XDG_CONFIG_HOME}/aws/config"
    CLOUDSDK_COMPUTE_REGION "europe-west1"
    CLOUDSDK_COMPUTE_ZONE   "europe-west1-b"
)
for k v in "${(@kv)env_vars}"; export "$k=$v"
unset env_vars
#[⫶] user env

typeset -U fpath=(
    ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions
    ${fpath}
)

#[≟] autoload zshenv.d functions (all shells)
for f in ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions/*(N:t); {
  emulate zsh -LRc "autoload $f"
}

#[≟] source zshenv.d/auto.d files (all shells), name order, skip templates
for rc in ${XDG_CONFIG_HOME}/zsh/zshenv.d/auto.d/*(.Non); {
  [[ $rc == *.auto.tmpl ]] && continue
  . $rc
}
