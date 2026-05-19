# small functions definitions

is_macos()  { [[ "$OSTYPE" =~ ^darwin ]]; }


# autoload functions from zsh/functions
for f in ${XDG_CONFIG_HOME}/zsh/functions/**(:t); {
  emulate zsh -LRc "autoload $f"
}

emulate zsh -LRc "autoload -Uz compinit" && compinit
