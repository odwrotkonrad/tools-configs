#!/bin/zsh
#>[what]
#   generate zsh completion files
#   user-space bins -> ${XDG_STATE_HOME}/zsh/completions, root-space bins -> /etc/zsh/zshrc.d/completions
#/[what]

emulate -LR zsh
setopt errexit
umask 002

##[>] 🤖🤖
autoload -Uz fn-log-msg

comp_dir_user=${XDG_STATE_HOME}/zsh/completions
comp_dir_root=/etc/zsh/zshrc.d/completions

comp_dir_get() {
    if [[ "$(whence -p $1)" == ${HOME}/* ]] { print -r -- $comp_dir_user; return }
    print -r -- $comp_dir_root
}

comp_file_write() {
    local dir=$(comp_dir_get $1)
    fn-log-msg -t 'completions(write)' -- "$1 -> $dir/$2"
    if [[ $dir == $comp_dir_root ]] {
        #[why] 🤖 install -m 0644: sudo resets umask to root's, so a bare `cp` leaves the file 0600 (root-only) and every other user's compinit fails "permission denied" reading it. mode must be world-readable
        sudo install -m 0644 /dev/stdin $dir/$2
        return
    }
    cp -f /dev/stdin $dir/$2
}

comp_file_fetch() {
    if [[ -e "$(comp_dir_get $1)/$2" ]] {
        fn-log-msg -t 'completions(skip)' -- "$1 -> $2 cached"
        return
    }
    comp_file_write $1 $2 < <(curl -fsSL $3)
}

comp_file_write rg _rg < <(rg --generate=complete-zsh)
comp_file_write che _che < <(che completion zsh)
comp_file_write asdf _asdf < <(asdf completion zsh)
comp_file_write codex _codex < <(codex completion zsh)
comp_file_write kubectl _kubectl < <(kubectl completion zsh)
comp_file_write docker _docker < <(docker completion zsh)
comp_file_write kind _kind < <(kind completion zsh)
comp_file_write kubectx _kubectx < "$(asdf where kubectx)/completion/_kubectx.zsh"
comp_file_write kubens _kubens < "$(asdf where kubectx)/completion/_kubens.zsh"

comp_file_fetch go _golang https://raw.githubusercontent.com/zsh-users/zsh-completions/398b4b74775102da7bc6a510a08d0914592f9e62/src/_golang
comp_file_fetch claude _claude https://raw.githubusercontent.com/wbingli/zsh-claudecode-completion/01f50d4a8a98b91cf6d9359deb37d60668c49806/_claude
##[<] 🤖🤖
