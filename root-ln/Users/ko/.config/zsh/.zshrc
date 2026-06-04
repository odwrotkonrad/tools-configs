#[≟] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

for rc in ${XDG_CONFIG_HOME}/zsh/rc.d/*.zsh(on); {
  . $rc
}

emulate zsh -LRc "autoload -Uz compinit" && compinit
