#[I] source all files from zsh/rc.d in ascending by name order
for rc in ${XDG_CONFIG_HOME}/zsh/rc.d/*.zsh(on); {
  . $rc
}

#> https://asdf-vm.com/guide/getting-started.html#_2-configure-asdf
[[ ! -s "${ASDF_DATA_DIR}/completions/_asdf" ]] && asdf completion zsh > "${ASDF_DATA_DIR}/completions/_asdf"


#> https://docs.brew.sh/Installation
eval "$(/opt/homebrew/bin/brew shellenv)" 

#> https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"                 

#> https://github.com/junegunn/fzf#setting-up-shell-integration
. <(fzf --zsh)
