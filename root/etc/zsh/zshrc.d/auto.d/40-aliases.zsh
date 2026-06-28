##[>] git
alias a-rt-git-interactive-rebase="git rebase --interactive HEAD~10"
alias a-rt-git-log-pretty="git log --pretty=format:'%h %ar %s' --decorate -n 10"
alias a-rt-git-remotes-all-list="git remote --verbose"
alias a-rt-git-stash-all="git stash --include-untracked"
alias a-rt-git-status-all="git stash --show-stash"
##[<] git

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

##[>] suffix aliases >[what] $ man zshbuiltins (alias -s)
() {
  local terminal=any ext opener
  [[ $TERM_PROGRAM == vscode ]] && terminal=vscode
  [[ $TERM == xterm-kitty ]] && terminal=kitty
  get-term-open-files-with $terminal | while IFS== read -r ext opener; do
    alias -s -- "$ext"="$opener"
  done
}
##[<] suffix aliases

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

#>[what] pstree
# -g graphics (2 = VT100)
# -p process id
# -s match string
#/[what]
alias a-rt-process-list-tree+='pstree -g 2 -p '
alias a-rt-process-list-tree-search+='pstree -g 2 -s '
##[<] processes

##[>] claude >[what]
# --permission-mode dontAsk - skip prompts, deny ungranted
# --append-system-prompt    - append to default system prompt
#/[what]

#[why] claude still asks questions in dontAsk mode
alias a-rt-claude-no-ask='claude --permission-mode dontAsk --append-system-prompt "IMPORTANT! Never ask user any questions! User your best judgement when in doubt!"'
##[<] claude

##[>] other
#>[what] fc - zsh history builtin
#  -l - list to stdout
#  -n - no event numbers
#/[what]
alias a-rt-history-file-contents-show="fc -ln 1"   #[what] from event 1

alias a-rt-keystrokes-listen-output-raw="kitten show-key -m kitty" #[what] raw key sequences, for keybindings

#[what] ssh -G print config
alias a-rt-ssh-show-config="ssh -G localhost"

#>[what] prometheus
# --config.file       - config path
# --storage.tsdb.path - tsdb on-disk path
#/[what]
alias prometheus="prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=${XDG_STATE_HOME:-$HOME/.local/state}/prometheus"
##[<] other
