#[≟] 2nd file sourced after /etc/zshenv

typeset -U fpath=(
    ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions
    ${fpath}
)

#[≟] autoload zshenv.d functions (all shells)
for f in ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions/*(N:t); {
  emulate zsh -LRc "autoload $f"
}

#[≟] source zshenv.d/auto.d files (all shells) in ascending by name order
for rc in ${XDG_CONFIG_HOME}/zsh/zshenv.d/auto.d/*.zsh(Non); {
  . $rc
}
