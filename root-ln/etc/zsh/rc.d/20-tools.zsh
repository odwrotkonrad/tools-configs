#[…] pyenv
eval "$(pyenv init - zsh)"
#[⫶]

#[…] python
export PYTHONPATH=/usr/local/scripts/python${PYTHONPATH:+:${PYTHONPATH}}
#[⫶]

#[…] fzf
#>[⌖]
# https://github.com/junegunn/fzf#setting-up-shell-integration
# $ man fzf
#/[⌖]
. <(fzf --zsh)
#[⫶]

#[…] direnv
#[⌖] https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"
#[⫶]

#[…] rg completions
[[ ! -s "/etc/zsh/completions/_rg" ]] && rg --generate=complete-zsh > "/etc/zsh/completions/_rg"
#[⫶]
