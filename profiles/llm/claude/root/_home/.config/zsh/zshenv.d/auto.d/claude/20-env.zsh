##[>] 🤖🤖
#[why] zshenv, not zshrc: claude reads CLAUDE_CONFIG_DIR wherever it is invoked, and a value only
#   interactive shells carry sends a login shell and a `zsh -lc` to different config dirs. one of
#   them then finds no credential and asks for a login
setopt allexport

CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
CLAUDE_CODE_SKIP_PROMPT_HISTORY=0
CLAUDE_CODE_NEW_INIT=1

unsetopt allexport
##[<] 🤖🤖
