# pyenv #[what] init pyenv: shims on PATH, completions, rehash
eval "$(pyenv init - zsh)"

# fzf #[what] load shell integration: keybindings + completion #[where]https://github.com/junegunn/fzf#setting-up-shell-integration $ man fzf
. <(fzf --zsh)
