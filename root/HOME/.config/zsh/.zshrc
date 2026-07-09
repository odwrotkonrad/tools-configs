#[what] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/{functions,completions}
    ${XDG_STATE_HOME}/zsh/completions
)

fn-insert fpath $funcs
fn-autoload-functions $funcs
emulate zsh -LRc "autoload -Uz compinit" && compinit

fn-source ${XDG_CONFIG_HOME}/zsh/zshrc.d/auto.d

# had to be disabled for loading configs, renabling here
setopt localoptions localtraps
