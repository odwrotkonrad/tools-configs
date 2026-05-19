alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gr="git remote -v"

alias bl="brew list"
alias bu="brew update && brew upgrade"

alias ssh_show_config="ssh -G localhost"

alias stat_h='stat -f "%HT | %A | %u(%Su):%g(%Sg) | %z bytes | %N"'

alias hist_refresh="fc -RL"

# list
#   -l long format
#   -A show hidden files except . and ..
#   -h readable size output
#   -F denote inode type by symbol
#   -G colorized output
#   -S sort by size
#   -W display whiteouts
alias als='ls -lhAFGSW'

# list attributes
#   -O show file flags (chflags)
#   -@ show extended attributes (xattr)
alias alsa='als -O@%'

alias ll='noglob list_dir_contents'

# man 
alias amans-='man -f -o' ## show relevant manpages list
alias amanl-='man -a -w' ## show manpages as filepaths list
alias amanp='manpath'    ## show manpath

