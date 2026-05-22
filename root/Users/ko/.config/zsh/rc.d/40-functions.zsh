# for f in ${XDG_CONFIG_HOME}/zsh/functions/**(:t); {
#   emulate zsh -LRc "autoload $f"
# }

emulate zsh -LRc "autoload -Uz compinit" && compinit
