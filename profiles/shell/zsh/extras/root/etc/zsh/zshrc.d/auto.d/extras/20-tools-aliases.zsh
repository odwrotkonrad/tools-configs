##[>] git
alias a-rt-git-interactive-rebase="git rebase --interactive HEAD~10"
alias a-rt-git-log-pretty="git log --pretty=format:'%h %ar %s' --decorate -n 10"
alias a-rt-git-remotes-all-list="git remote --verbose"
alias a-rt-git-stash-all="git stash --include-untracked"
alias a-rt-git-status-all="git stash --show-stash"
##[<] git

##[>] claude >[what]
# --permission-mode dontAsk - skip prompts, deny ungranted
# --append-system-prompt    - append to default system prompt
#/[what]

#[why] claude still asks questions in dontAsk mode
alias a-rt-claude-no-ask='claude --permission-mode dontAsk --append-system-prompt "IMPORTANT! Never ask user any questions! User your best judgement when in doubt!"'
##[<] claude

##[>] processes
#>[what] pstree
# -g graphics (2 = VT100)
# -p process id
# -s match string
#/[what]
alias a-rt-process-list-tree+='pstree -g 2 -p '
alias a-rt-process-list-tree-search+='pstree -g 2 -s '
##[<] processes

##[>] other
alias a-rt-keystrokes-listen-output-raw="kitten show-key -m kitty" #[what] raw key sequences, for keybindings

#[what] ssh -G print config
alias a-rt-ssh-show-config="ssh -G localhost"

#>[what] prometheus
# --config.file       - config path
# --storage.tsdb.path - tsdb on-disk path
#/[what]
alias prometheus="prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=${XDG_STATE_HOME:-$HOME/.local/state}/prometheus"
##[<] other
