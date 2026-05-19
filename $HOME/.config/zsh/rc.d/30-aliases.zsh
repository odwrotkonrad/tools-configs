### [a]lias

## [g]it
alias aga="git add ."           # [a]dd
alias agc="git commit -m"       # [c]ommit
alias agp="git push"            # [p]ush
alias aglr="git remote -v"      # [l]ist [r]emotes

## [b]rew
alias abl="brew list"           # [l]ist installed packages
alias abu="brew update && brew upgrade" # [u]update remotes; install upgrades

## [ss]h
alias asssc="ssh -G localhost"  # [s]how [c]onfig

## [st]at
alias asts='stat -f "%HT | %A | %u(%Su):%g(%Sg) | %z bytes | %N"' # [s]imple view

## [l]s

# -l long format
# -A show hidden files except . and ..
# -h readable size output
# -F denote inode type by symbol
# -G colorized output
# -S sort by size
# -W display whiteouts
alias all='ls -lhAFGSW'     # [l]ist

# -O show file flags (chflags)
# -@ show extended attributes (xattr)
alias alsa='als -O@%'        # [l]ist [a]ttributes

## [m]an 
alias aml-='man -f -o'      # show relevant manpages [l]ist
alias amfl-='man -a -w'     # show manpages as [f]ilepaths [l]ist
alias amp='manpath'         # show [m]anpath

## other
alias ll='noglob list_dir_contents'
