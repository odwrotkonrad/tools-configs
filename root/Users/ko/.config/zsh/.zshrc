# 6th zsh file sourced, after /etc/zshrc; only for interactive shells

hash -d configs="$HOME/projects/configs" \
        projects="$HOME/projects"


typeset -U path=(${XDG_BIN_HOME} $path)

for rc in ${XDG_CONFIG_HOME}/zsh/rc.d/*.zsh(on); {
  . $rc
}
