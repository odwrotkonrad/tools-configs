##[>] env
setopt allexport

NVM_DIR="$XDG_CONFIG_HOME/nvm"

unsetopt allexport
##[<] env

##[>] 🤖🤖
#[why] guarded: nvm installs via che packages (dev/js/node profile), absent until that profile ran
[[ -f "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -f "$NVM_DIR/bash_completion" ]] && autoload -Uz bashcompinit && bashcompinit && . "$NVM_DIR/bash_completion"
##[<] 🤖🤖
