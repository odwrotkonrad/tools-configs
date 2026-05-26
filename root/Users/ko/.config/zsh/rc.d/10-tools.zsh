#[≟] Tools Configuration

#[≟] asdf
#[⌖] https://asdf-vm.com/guide/getting-started.html#_2-configure-asdf

[[ ! -s "${ZDOTDIR}/completions/_asdf" ]] && asdf completion zsh > "${ZDOTDIR}/completions/_asdf"

#[≟] nvm
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
. "$NVM_DIR/nvm.sh"
. "$NVM_DIR/bash_completion"

#[≟] Claude Code
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
export CLAUDE_CODE_SKIP_PROMPT_HISTORY=0
export CLAUDE_CODE_NEW_INIT=1
