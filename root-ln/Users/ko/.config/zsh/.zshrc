#[≟] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/{functions,completions}
    ${XDG_STATE_HOME}/zsh/completions
)

fn-rt-insert fpath $funcs
fn-rt-autoload-functions $funcs
fn-rt-source ${XDG_CONFIG_HOME}/zsh/zshrc.d/auto.d

emulate zsh -LRc "autoload -Uz compinit" && compinit

# had to be disabled for loading configs, renabling here
setopt localoptions localtraps
