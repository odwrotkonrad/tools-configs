### [a]lias


## [b]rew
alias sa_bl="brew list"                   # [l]ist installed packages
alias sa_bu="brew update && brew upgrade" # [u]update remotes; install upgrades


## [d]efaults
alias sa_dd="defaults delete"             # [d]elete
alias sa_df="defaults find"               # [f]ind
alias sa_dr="defaults read"               # [r]ead
alias sa_dw="defaults write"              # [w]rite


## [g]it
alias sa_ga="git add ."                     # [a]dd
alias sa_gc-="git commit -m"                # [c]ommit
alias sa_gh="git lg"                        # [h]istory of recent commits
alias sa_gir="git rebase -i HEAD~10"        # open [i]nteractive [r]ebase for recent commits
alias sa_glr="git remote -v"                # [l]ist [r]emotes
alias sa_gp="git push"                      # [p]ush
alias sa_gpf="git push --force-with-lease"  # [p]ush [f]orce safely
alias sa_gs="git status --short"            # [s]tatus compact
alias sa_gsa="git stash -u"                 # [s]tash all, including untracked files
alias sa_gsp="git stash pop"                # [s]tash [p]op
alias sa_gss="git stash show"               # [s]tash [s]how
alias sa_gst="git stash"                    # [s]tash [t]racked only


## [k]itten

alias sa_kki-="kitten show-key -m kitty"       # show [k]eys sequences [i]nteractively

## [l]aunch[c]tl - launchd interface

alias sa_lcb+="launchctl bootstrap"            # [b]ootstrap
alias sa_lcbo+="launchctl bootout --wait"      # [b]oot[o]ut
alias sa_lck+="launchctl kickstart -k"         # [k]ickstart  (-k - shutdown before starting)
alias sa_lcl="launchctl list"                  # [l]ist
alias sa_lcp+="launchctl print"                # [p]rint


## [ls]
# -A include hidden files
# -F denote inode type by symbol
# -G colorized output
# -h readable size output
# -l long format
# -S sort by size
# -W display whiteouts
alias sa_lslf='ls -lhAFGSW'     # [l]ist [f]iles

# -O show file flags (chflags)
# -@ show extended attributes (xattr)
alias sa_lslfa="all -O@%"       # [l]ist [f]iles with [a]ttributes

## [m]an
alias sa_ml-='man -f -o'      # [l]ist relevant manpages
alias sa_mlf-='man -a -w'     # [l]ist manpages as [f]ilepaths
alias sa_msp='manpath'        # [s]how [m]anpath

## [pl]util - property list utility
alias sa_plp+='plutil -p'                  # [p]rint
alias sa_pll+='plutil -lint'               # [l]int
alias sa_plc+='plutil -convert'            # [c]onvert
alias sa_plcj+='plutil -convert json'      # [c]onvert to json
alias sa_plcx+='plutil -convert xml1'      # [c]onvert to xml

## [ps] - process status
# -o specify output columns
# -ww wide output (do not truncate cmd)

alias sa_pslt='ps -o ppid,pid,uid,tty,start,command'       # [l]ist processes with [t]ty attached belonging to current user
alias sa_psltw='ps -ww -o ppid,pid,uid,tty,start,command'  # [lt] [w]ide


## [pst]ree - list processes as a tree
# -g specify graphics (2 = VT100)
# -p specify process id
# -s match string
alias sa_psttl+='pstree -g 2 -p '           # [l]ist processes specifying pid as [+]argument
alias sa_psttlc-='pstree -g 2 -p $$'        # [l]ist [c]urrent shell process
alias sa_pstts+='pstree -g 2 -s '           # [s]earch for string [+]argument


## [ss]h
alias sa_sssc="ssh -G localhost"          # [s]how [c]onfig

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
alias sa_sts+='stat -t "%Y-%m-%d %H:%M:%S" -f "
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

## [r]g - ripgrep

function sf_rg { command rg --max-columns=$(( COLUMNS - 5 )) "$@" }

# -g '*': glob matching all files bypasses ignore rules (.gitignore, .rgignore, etc.)
alias sa_rgc+='sf_rg -A1 -B3 '                                       # [c]ontext (1 line after, 3 lines before)
alias sa_rgcl+='sf_rg --count --no-multiline --no-multiline-dotall ' # [f]iles with lines with matches [c]ount
alias sa_rgcm+='sf_rg --count-matches '                              # [f]iles with matches [c]ount
alias sa_rgfs='sf_rg --files'                                        # [f]iles that would be [s]earched
alias sa_rgj+='sf_rg --json '                                        # [j]son output
alias sa_rgom+='sf_rg --only-matching --column '                     # [o]nly [m]atching text
alias sa_rgu+='sf_rg -g '                                            # search by [+]glob (do not read ignore files)
alias sa_rgsp+='sf_rg --sort=path '                                  # [s]ort by [p]ath lexicographically

## misc
alias sa_fld='noglob fn_list_dir' # [f]unction [l]ist [d]ir
