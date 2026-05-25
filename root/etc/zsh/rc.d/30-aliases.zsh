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

## [ls]
# -A include hidden files
# -F denote inode type by symbol
# -G colorized output
# -h readable size output
# -l long format
# -S sort by size
# -W display whiteouts
alias sa_list_directory='ls -lhAFGSW'

# -O show file flags (chflags)
# -@ show extended attributes (xattr)
alias sa_list_directory_attr="sa_list_directory -O@%"       # list with attributes

## manual pages
alias sa_manpage_list_pages-='man -f -o'
alias sa_manpage_list_files='man -a -w'
alias sa_manpage_show_manpath='manpath'

## processes

# ps
# -o specify output columns
# -ww wide output (do not truncate cmd)
alias sa_process_list_tty_current='ps -o ppid,pid,uid,tty,start,command'
alias sa_process_list_tty_current_verbose='ps -ww -o ppid,pid,uid,tty,start,command'


## pstree - list processes as a tree
# -g specify graphics (2 = VT100)
# -p specify process id
# -s match string
alias sa_process_list_tree+='pstree -g 2 -p '
alias sa_process_list_tree_search+='pstree -g 2 -s

## searching files

function sf_rg { command rg --max-columns=$(( COLUMNS - 5 )) "$@" }

alias sa_search_file_show_context+='sf_rg -A1 -B3 '
alias sa_search_files_glob_include_all+='sf_rg -g '
alias sa_search_files_no='sf_rg --files' # instead of searching list files that would be searched
alias sa_search_files_output_json+='sf_rg --json '
alias sa_search_files_output_line_count+='sf_rg --count --no-multiline --no-multiline-dotall '
alias sa_search_files_output_match_count+='sf_rg --count-matches '
alias sa_search_files_output_no_context+='sf_rg --only-matching --column '
alias sa_search_files_output_sort_lex+='sf_rg --sort=path '

## ssh
alias sa_ssh_show_config="ssh -G localhost"
