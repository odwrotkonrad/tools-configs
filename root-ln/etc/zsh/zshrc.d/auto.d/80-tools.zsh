# pyenv #[≟] init pyenv: shims on PATH, completions, rehash
eval "$(pyenv init - zsh)"

# fzf #[≟] load shell integration: keybindings + completion #[⌖]https://github.com/junegunn/fzf#setting-up-shell-integration $ man fzf
. <(fzf --zsh)

# direnv #[≟] hook into precmd to load/unload .envrc per dir #[⌖] https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"
