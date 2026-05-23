# Tools Configuration

# asdf #> https://asdf-vm.com/guide/getting-started.html#_2-configure-asdf

export ASDF_DATA_DIR="${XDG_STATE_HOME}/asdf"
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/.asdfrc"

[[ ! -s "${ZDOTDIR}/completions/_asdf" ]] && asdf completion zsh > "${ZDOTDIR}/completions/_asdf"

# direnv
eval "$(direnv hook zsh)" #> https://direnv.net/docs/hook.html

# fzf
. <(fzf --zsh) #> https://github.com/junegunn/fzf#setting-up-shell-integration

# nvm

export NVM_DIR="$XDG_CONFIG_HOME/nvm"
. "$NVM_DIR/nvm.sh"
. "$NVM_DIR/bash_completion"

# pyenv

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VERSION="3.14"
eval "$(pyenv init - zsh)"

# go

export GOPATH="${HOME}/go"

# claude
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
export CLAUDE_CODE_SKIP_PROMPT_HISTORY=0
export CLAUDE_CODE_NEW_INIT=1
