eval "$(pyenv init - zsh)"

# fzf #> https://github.com/junegunn/fzf#setting-up-shell-integration
. <(fzf --zsh)

# direnv #> https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"
