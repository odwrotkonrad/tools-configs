#[what] 6th zsh file sourced, after /etc/zshrc; only for interactive shells

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshrc.d/{functions,completions}
    ${XDG_STATE_HOME}/zsh/completions
)

fn-insert fpath $funcs
fn-autoload-functions $funcs

autoload -U compinit && compinit

##[>] 🤖🤖 register after compinit; _deep_files + its zstyles (file-types picks kinds per command) live in /etc/zsh 70-completions.zsh
compdef _deep_files cd vim vi nano cat less bat code ls stat
compdef _deep_files_tilde -tilde-
compdef _deep_command -command-
##[<] 🤖🤖

fn-source ${XDG_CONFIG_HOME}/zsh/zshrc.d/auto.d

# had to be disabled for loading configs, renabling here
setopt localoptions localtraps
