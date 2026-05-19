### [a]lias

## [b]rew
alias abl="brew list"                   # [l]ist installed packages
alias abu="brew update && brew upgrade" # [u]update remotes; install upgrades

## [d]efaults
alias add="defaults find"               # [f]ind
alias adf="defaults delete"             # [d]elete
alias adr="defaults read"               # [r]ead
alias adw="defaults write"              # [w]rite

## [g]it
alias aga="git add ."                   # [a]dd
alias agc-="git commit -m"              # [c]ommit
alias aglr="git remote -v"              # [l]ist [r]emotes
alias agp="git push"                    # [p]ush

## [l]s

# -l long format
# -A show hidden files
# -h readable size output
# -F denote inode type by symbol
# -G colorized output
# -S sort by size
# -W display whiteouts
alias allf='ls -lhAFGSW'     # [l]ist [f]iles

# -O show file flags (chflags)
# -@ show extended attributes (xattr)
alias allfa="all -O@%"       # [l]ist [f]iles with [a]ttributes

## [m]an 
alias amsfl-='man -a -w'     # [s]how manpages as [f]ilepaths [l]ist
alias amsl-='man -f -o'      # [s]how relevant manpages [l]ist
alias amsp='manpath'         # [s]how [m]anpath

## [ss]h
alias asssc="ssh -G localhost"          # [s]how [c]onfig

## [st]at
# -t: Format for string time output (YYYY-MM-DD HH:MM:SS)
# -f: Format string
#   %HT - Human readable file type
#   %N  - File name
#   %T  - One-character file type
#
#   %Lp - Permission bits in octal "644"
#   %Sp - Symbolic permissions string "-rw-r--r--"
#   %Sf - File flags
#
#   %Su - Owner name
#   %u  - Owner ID 
#   %Sg - Group name
#   %g  - Group ID
#
#   %l  - Hard links count
#   %z  - File size in bytes
#   %i  - Inode number
#   %d  - Device ID
#
#   %SB - Time of birth
#   %Sa - Time of last access
#   %Sm - Time of last modification
#   %Sc - Time of last metadata change

# [s]how file info
alias asts-='stat -t "%Y-%m-%d %H:%M:%S" -f "
🏷️ %HT | %N%T
🔐 %Lp [%Sp] | 🚩 %Sf
👤 %Su(%u) 👥 %Sg(%g)
🔗 %l | 🐘 %z B | 🪪 %i |  🏗️ %d

---- 🕒 ----
🐣 %SB
👁️ %Sa
📝 %Sm
⚙️ %Sc
"'

## ----
alias ll='noglob list_dir_contents'
