#[what] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/{functions,completions}
    ${XDG_STATE_HOME}/zsh/completions
)

fn-insert fpath $funcs
fn-autoload-functions $funcs

autoload -U compinit && compinit

##[>] 🤖🤖 register after compinit; _cd_deep / _file_deep + their zstyles live in /etc/zsh 70-completions.zsh
compdef _cd_deep cd
compdef _file_deep code vim vi nano cat less bat
##[<] 🤖🤖

fn-source ${XDG_CONFIG_HOME}/zsh/zshrc.d/auto.d

# had to be disabled for loading configs, renabling here
setopt localoptions localtraps
