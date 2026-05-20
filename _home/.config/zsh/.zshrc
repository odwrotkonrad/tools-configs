# 6th zsh file sourced, after /etc/zshrc; only for interactive shells

hash -d dotfiles="$HOME/.local/share/dotfiles" \
        projects="$HOME/.local/share/projects"


typeset -U path=(${XDG_BIN_HOME} $path)

for rc in ${XDG_CONFIG_HOME}/zsh/rc.d/*.zsh(on); {
  . $rc
}

