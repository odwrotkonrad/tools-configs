typeset -U fpath=(
    /opt/homebrew/share/zsh/site-functions
    /etc/zsh/functions
    ${fpath}
)

for f in /etc/zsh/functions/**(:t); {
  emulate zsh -LRc "autoload $f"
}
