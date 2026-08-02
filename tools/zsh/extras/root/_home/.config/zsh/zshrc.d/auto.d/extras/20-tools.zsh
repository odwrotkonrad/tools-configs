##[>] env
setopt allexport

NVM_DIR="$XDG_CONFIG_HOME/nvm"
CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
CLAUDE_CODE_SKIP_PROMPT_HISTORY=0
CLAUDE_CODE_NEW_INIT=1

unsetopt allexport
##[<] env

##[>] 🤖🤖
#[why] nvm is a mac/brew install: absent on linux hosts and in the sandbox image
[[ -f "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -f "$NVM_DIR/bash_completion" ]] && autoload -Uz bashcompinit && bashcompinit && . "$NVM_DIR/bash_completion"
##[<] 🤖🤖
