##[>] env
setopt allexport

NVM_DIR="$XDG_CONFIG_HOME/nvm"

unsetopt allexport
##[<] env

##[>] 🤖🤖
#[why] nvm is a mac/brew install: absent on linux hosts and in the sandbox image
[[ -f "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -f "$NVM_DIR/bash_completion" ]] && autoload -Uz bashcompinit && bashcompinit && . "$NVM_DIR/bash_completion"
##[<] 🤖🤖
