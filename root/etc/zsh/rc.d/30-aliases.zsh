### [a]lias

## [g]it

alias sa_git_interactive_rebase="git rebase --interactive HEAD~10"
alias sa_git_remotes_all_list="git remote --verbose"
alias sa_git_stash_all="git stash --include-untracked"
alias sa_git_status_all="git stash --show-stash"

## [h]istory
alias sa_history_list_show="fc -ln 1"   # all in-memory history

## [k]eys

alias sa_keys_listen-="kitten show-key -m kitty"

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


## [r]g - ripgrep

function sf_rg { command rg --max-columns=$(( COLUMNS - 5 )) "$@" }

alias sa_rgc+='sf_rg -A1 -B3 '                                          # [c]ontext (1 line after, 3 lines before)
alias sa_rgg+='sf_rg -g '                                               # [g]lob (with ignore ignore files)
alias sa_rgj+='sf_rg --json '                                           # [j]son output
alias sa_rglc+='sf_rg --count --no-multiline --no-multiline-dotall '    # list files [l]ines with matches [c]ount
alias sa_rgmc+='sf_rg --count-matches '                                 # list files with [m]atches [c]ount
alias sa_rgom+='sf_rg --only-matching --column '                        # [o]nly [m]atching text (without surrounding characters)
alias sa_rgs='sf_rg --files'                                            # list files that would be [s]earched (do not search)
alias sa_rgsl+='sf_rg --sort=path '                                     # [s]ort by path [l]exicographically

## [ss]h
alias sa_sssc="ssh -G localhost"        # [s]how [c]onfig
