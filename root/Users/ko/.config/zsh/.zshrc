# 6th zsh file sourced, after /etc/zshrc; only for interactive shells

export GIT_HOOKSDIR="${XDG_CONFIG_HOME}/git/hooks"

for rc in ${XDG_CONFIG_HOME}/zsh/rc.d/*.zsh(on); {
  . $rc
}

emulate zsh -LRc "autoload -Uz compinit" && compinit
