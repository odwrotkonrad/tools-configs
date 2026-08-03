##[>] files
#>[what] ls
# -A hidden files
# -F type by symbol
# -G color
# -h readable size
# -l long
# -S sort by size
# -W whiteouts
# -O file flags (chflags)
# -@ xattr
#/[what]
alias a-rt-list-directory='ls -lhAFGSW'
alias a-rt-list-directory-attr="a-rt-list-directory -O@%"

###[>] rg
#>[what] rg
# -A<num> context lines after match
# -B<num> context lines before match
# -g glob, overrides ignore heuristics
#/[what]

#[why] --max-columns dynamic from terminal width
function fn-root-rg { command rg --max-columns=$(( COLUMNS - 5 )) "$@" }
alias a-rt-search-file-show-context+='fn-root-rg -A1 -B3 '
alias a-rt-search-files-glob-include-all+='fn-root-rg -g '
alias a-rt-search-files-no='fn-root-rg --files' #[what] list searchable files, no search
alias a-rt-search-files-output-json+='fn-root-rg --json '
alias a-rt-search-files-output-line-count+='fn-root-rg --count --no-multiline --no-multiline-dotall '
alias a-rt-search-files-output-match-count+='fn-root-rg --count-matches '
alias a-rt-search-files-output-no-context+='fn-root-rg --only-matching --column '
alias a-rt-search-files-output-sort-lex+='fn-root-rg --sort=path '
###[<] rg
##[<] files

##[>] manual pages
#>[what] man
# -f whatis (lists pages)
# -o non-localized pages
# -a all matches, not just first
# -w page location, not page
#/[what]
alias a-rt-manpage-list-pages='man -f -o'
alias a-rt-manpage-list-files='man -a -w'
alias a-rt-manpage-show-manpath='manpath'
##[<] manual pages

##[>] processes
#>[what] ps
# -o output columns
# -ww wide, no cmd truncation
#/[what]
alias a-rt-process-list-tty-current='ps -o ppid,pid,uid,tty,start,command'
alias a-rt-process-list-tty-current-verbose='ps -ww -o ppid,pid,uid,tty,start,command'
##[<] processes

##[>] other
#>[what] fc - zsh history builtin
#  -l - list to stdout
#  -n - no event numbers
#/[what]
alias a-rt-history-file-contents-show="fc -ln 1"   #[what] from event 1
##[<] other
