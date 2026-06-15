#[…] env
setopt allexport

NVM_DIR="$XDG_CONFIG_HOME/nvm"
CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
CLAUDE_CODE_SKIP_PROMPT_HISTORY=0
CLAUDE_CODE_NEW_INIT=1

unsetopt allexport
#[⫶] env

. "$NVM_DIR/nvm.sh"
. "$NVM_DIR/bash_completion"
