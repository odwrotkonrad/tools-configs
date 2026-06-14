#[…] pyenv
eval "$(pyenv init - zsh)"
#[⫶] pyenv

#[…] python
export PYTHONPATH=/usr/local/scripts/python${PYTHONPATH:+:${PYTHONPATH}}
#[⫶] python

#[…] fzf
#>[⌖]
# https://github.com/junegunn/fzf#setting-up-shell-integration
# $ man fzf
#/[⌖]
. <(fzf --zsh)
#[⫶] fzf

#[…] direnv
#[⌖] https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"
#[⫶] direnv

#[…] rg completions
[[ ! -s "/etc/zsh/zshrc.d/completions/_rg" ]] && rg --generate=complete-zsh > "/etc/zsh/zshrc.d/completions/_rg"
#[⫶] rg completions
