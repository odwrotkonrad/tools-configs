# pyenv #[what] init pyenv: shims on PATH, completions, rehash
eval "$(pyenv init - zsh)"

# fzf #[what] load shell integration: keybindings + completion #[where]https://github.com/junegunn/fzf#setting-up-shell-integration $ man fzf
. <(fzf --zsh)

# direnv #[what] hook into precmd to load/unload .envrc per dir #[where] https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"
