#[≟] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

typeset -U fpath=(
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/functions
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/completions
    ${XDG_STATE_HOME}/zsh/completions
    ${fpath}
)

for f in ${XDG_CONFIG_HOME}/zsh/zshrc.d/functions/*(N:t); {
  emulate zsh -LRc "autoload $f"
}

for rc in ${XDG_CONFIG_HOME}/zsh/zshrc.d/auto.d/*.zsh(on); {
  . $rc
}

emulate zsh -LRc "autoload -Uz compinit" && compinit
