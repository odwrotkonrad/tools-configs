#[…] git [≟] the stupid content tracker
alias a-rt-git-interactive-rebase="git rebase --interactive HEAD~10"
alias a-rt-git-log-pretty="git log --pretty=format:'%h %ar %s' --decorate -n 10"
alias a-rt-git-remotes-all-list="git remote --verbose"
alias a-rt-git-stash-all="git stash --include-untracked"
alias a-rt-git-status-all="git stash --show-stash"
#[⫶]

#[…] files
#>[≟] ls - list directory contents
# -A include hidden files
# -F denote inode type by symbol
# -G colorized output
# -h readable size output
# -l long format
# -S sort by size
# -W display whiteouts
# -O show file flags (chflags)
# -@ show extended attributes (xattr)
#/[≟]
alias a-rt-list-directory='ls -lhAFGSW'
alias a-rt-list-directory-attr="a-rt-list-directory -O@%"

#[……] rg
#>[≟] rg - recursively search the current directory for lines matching a pattern
# -A<num> - show <num> context lines after a match
# -B<num> - show <num> context lines before a match
# -g - specify glob, overrides all other ignore herustics
#/[≟]

#[≟] rg wrapper limiting column width to terminal size
#[∵] to set --max-columns dynamically based on current terminal width
function fn-rt-rg { command rg --max-columns=$(( COLUMNS - 5 )) "$@" }
alias a-rt-search-file-show-context+='fn-rt-rg -A1 -B3 '
alias a-rt-search-files-glob-include-all+='fn-rt-rg -g '
alias a-rt-search-files-no='fn-rt-rg --files' #[≟] instead of searching list files that would be searched
alias a-rt-search-files-output-json+='fn-rt-rg --json '
alias a-rt-search-files-output-line-count+='fn-rt-rg --count --no-multiline --no-multiline-dotall '
alias a-rt-search-files-output-match-count+='fn-rt-rg --count-matches '
alias a-rt-search-files-output-no-context+='fn-rt-rg --only-matching --column '
alias a-rt-search-files-output-sort-lex+='fn-rt-rg --sort=path '
#[⫶⫶]
#[⫶]

#[…] suffix aliases >[≟] $ man zshbuiltins (alias -s)
() {
  local terminal=any ext opener
  [[ $TERM_PROGRAM == vscode ]] && terminal=vscode
  [[ $TERM == xterm-kitty ]] && terminal=kitty
  s-rt-gen-term-open-files-with $terminal | while IFS== read -r ext opener; do
    alias -s -- "$ext"="$opener"
  done
}
#[⫶]

#[…] manual pages
#>[≟] man - display online manual documentation pages
# -f - emualte whatis (lists interesting pages)
# -o - non-localized pages, useful if locale would be set to non english
# -a - display all, not just the first match
# -w - display location of a manual page, not manual itself
#/[≟]
alias a-rt-manpage-list-pages='man -f -o'
alias a-rt-manpage-list-files='man -a -w'
alias a-rt-manpage-show-manpath='manpath'
#[⫶]

#[…] processes
#>[≟] ps – process status
# -o specify output columns
# -ww wide output (do not truncate cmd)
#/[≟]
alias a-rt-process-list-tty-current='ps -o ppid,pid,uid,tty,start,command'
alias a-rt-process-list-tty-current-verbose='ps -ww -o ppid,pid,uid,tty,start,command'

#>[≟] pstree – list processes as a tree
# -g specify graphics (2 = VT100)
# -p specify process id
# -s match string
#/[≟]
alias a-rt-process-list-tree+='pstree -g 2 -p '
alias a-rt-process-list-tree-search+='pstree -g 2 -s '
#[⫶]

#[…] claude >[≟] agentic coding tool
# --permission-mode dontAsk - skip permission prompts for the session, deny if not explicity granted permission
# --append-system-prompt    - append text to the default system prompt
#/[≟]

#[∵] it happens claude tries to ask questions in dontAsk mode
alias a-rt-claude-no-ask='claude --permission-mode dontAsk --append-system-prompt "IMPORTANT! Never ask user any questions! User your best judgement when in doubt!"'
#[⫶]

#[…] other

#>[≟] fc - zsh builtin, controls the interactive history mechanism
#  -l - list to stdout
#  -n - do not show event numbers
#/[≟]
alias a-rt-history-file-contents-show="fc -ln 1"   #[≟] starting from event no 1

alias a-rt-keystrokes-listen-output-raw="kitten show-key -m kitty" #[≟] start listening for keystrokes to output raw sequences, useful for building keybidnings

#[≟] ssh - OpenSSH remote login client, -G print configuration
alias a-rt-ssh-show-config="ssh -G localhost"

#>[≟] prometheus - monitoring system & time series database
# --config.file       - path to prometheus configuration
# --storage.tsdb.path - on-disk location for the time series database
#/[≟]
alias prometheus="prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=${XDG_STATE_HOME:-$HOME/.local/state}/prometheus"
#[⫶]
