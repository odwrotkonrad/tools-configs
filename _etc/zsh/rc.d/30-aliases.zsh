### [a]lias


## [b]rew
alias abl="brew list"                   # [l]ist installed packages
alias abu="brew update && brew upgrade" # [u]update remotes; install upgrades


## [d]efaults
alias add="defaults delete"             # [d]elete
alias adf="defaults find"               # [f]ind
alias adr="defaults read"               # [r]ead
alias adw="defaults write"              # [w]rite


## [g]it
alias aga="git add ."                   # [a]dd
alias agc-="git commit -m"              # [c]ommit
alias aglr="git remote -v"              # [l]ist [r]emotes
alias agp="git push"                    # [p]ush
alias agsa="git stash -u"               # [s]tash all, including untracked files
alias agsp="git stash pop"              # [s]tash [p]op
alias agss="git stash show"             # [s]tash [s]how
alias agst="git stash"                  # [s]tash [t]racked only
alias agir="git rebase -i HEAD~10"      # open [i]nteractive [r]ebase for recent commits


## [k]itten

alias akki-="kitten show-key -m kitty"       # show [k]eys sequences [i]nteractively

## [l]aunch[c]tl - launchd interface

alias alcb+="launchctl bootstrap"            # [b]ootstrap
alias alcbo+="launchctl bootout --wait"      # [b]oot[o]ut
alias alck+="launchctl kickstart -k"         # [k]ickstart  (-k - shutdown before starting)
alias alcl="launchctl list"                  # [l]ist
alias alcp+="launchctl print"                # [p]rint


## [ls]
# -A include hidden files
# -F denote inode type by symbol
# -G colorized output
# -h readable size output
# -l long format
# -S sort by size
# -W display whiteouts
alias alslf='ls -lhAFGSW'     # [l]ist [f]iles

# -O show file flags (chflags)
# -@ show extended attributes (xattr)
alias alslfa="all -O@%"       # [l]ist [f]iles with [a]ttributes

## [m]an 
alias aml-='man -f -o'      # [l]ist relevant manpages
alias amlf-='man -a -w'     # [l]ist manpages as [f]ilepaths
alias amsp='manpath'        # [s]how [m]anpath

## [pl]util - property list utility
alias aplp+='plutil -p'                  # [p]rint
alias apll+='plutil -lint'               # [l]int
alias aplc+='plutil -convert'            # [c]onvert 
alias aplcj+='plutil -convert json'      # [c]onvert to json
alias aplcx+='plutil -convert xml1'      # [c]onvert to xml

## [ps] - process status
# -o specify output columns
# -ww wide output (do not truncate cmd)

alias apslt='ps -o ppid,pid,uid,tty,start,command'       # [l]ist processes with [t]ty attached belonging to current user
alias apsltw='ps -ww -o ppid,pid,uid,tty,start,command'  # [lt] [w]ide


## [pst]ree - list processes as a tree
# -g specify graphics (2 = VT100)
# -p specify process id
# -s match string 
alias apsttl+='pstree -g 2 -p '           # [l]ist processes specifying pid as [+]argument
alias apsttlc-='pstree -g 2 -p $$'        # [l]ist [c]urrent shell process
alias apstts+='pstree -g 2 -s '           # [s]earch for string [+]argument


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
alias asts+='stat -t "%Y-%m-%d %H:%M:%S" -f "
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

## misc
alias afld='noglob fn_list_dir' # [f]unction [l]ist [d]ir


