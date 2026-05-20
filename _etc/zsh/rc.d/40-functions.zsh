typeset -U fpath=(
    /etc/zsh/functions
    ${fpath}
)

for f in /etc/zsh/functions/**(:t); {
  emulate zsh -LRc "autoload $f"
}
