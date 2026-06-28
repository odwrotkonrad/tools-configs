#!/bin/zsh

emulate -LR zsh
setopt errexit localtraps
autoload -Uz fn-log-msg

: ${HOME:?HOME must be set}

if (( EUID != 0 )) { print -u2 "must run as root"; exit 1 }

typeset configs configs_owner configs_user home
typeset -a dirs_user_space dirs_root_space dirs_system_space dirs_system_space_world

function mk_dirs {
  local -a opt_user opt_chown opt_chmod opt_umask
  local dir
  zparseopts -D -E -user:=opt_user -owner:=opt_chown -perms:=opt_chmod -umask:=opt_umask  #[what] 🤖🤖 --user: created owned at birth (no chown). --umask: scopes creation mode
  if (( $#opt_umask )) { local saved=$(umask); umask $opt_umask[2]; trap "umask $saved" EXIT }  #[what] 🤖🤖 localtraps restores on return
  for dir ( ${(o)@} ) {  #[what] 🤖🤖 (o) lexical sort: parents before children
    if [[ ! -d $dir ]] {
      if (( $#opt_user )) { sudo -u $opt_user[2] mkdir $dir } else { mkdir $dir }  #[what] 🤖🤖 no -p, parents made first
      fn-log-msg -t mkdir -- $dir
      if (( $#opt_chown )) { chown $opt_chown[2] $dir; fn-log-msg -t chown -- "$dir $opt_chown[2]" }  #[what] 🤖🤖 no -R, per-dir, custom owner only
      if (( $#opt_chmod )) { chmod $opt_chmod[2] $dir; fn-log-msg -t chmod -- "$dir $opt_chmod[2]" }
    }
  }
}

configs=${1:-$HOME/projects/configs}
configs_owner=$(stat -f '%Su:%Sg' -- $configs)
configs_user=${SUDO_USER:-${configs_owner%%:*}} #[what] 🤖🤖 invoking user, owns user-space dirs
home=$HOME

#[what] 🤖🤖 braces enumerate parents+children, empty element {,..} keeps parent itself
#[why] mk_dirs sorts (o) so parents precede children for plain mkdir (no -p)
dirs_user_space=(
  .cache{,/homebrew,/zsh}
  .config{,/codex}
  .local{,/bin,/share,/state,/state/asdf,/state/codex,/state/codex/log,/state/homebrew,/state/log,/state/vim,/state/vim/undo,/state/zsh,/state/zsh/completions} #[what] 🤖🤖
  ScreenCapture
)
dirs_user_space=( $home/${^dirs_user_space} )

dirs_root_space=( /var/root/{.cache{,/zsh},.config,.local{,/bin,/share,/state{,/zsh{,/completions}}}} )

dirs_system_space=(
  /var/log/{grafana,jaeger,loki,prometheus,dir_size_exporter,port_exporter,otelcol}
  /usr/local/var{,/grafana,/prometheus,/dir_size_exporter} #[what] 🤖🤖
  /var/custom{,/cache} #[what] 🤖🤖
)

dirs_system_space_world=(
  /var/custom/cache/get-term-open-files-with
)


mk_dirs --umask 027 --user $configs_user $dirs_user_space                          #[what] 🤖🤖 user-owned at birth, 0750 (group read, no world)
mk_dirs --umask 022 $dirs_root_space                                               #[what] 🤖🤖 root:wheel default, 0755 (world-readable)
mk_dirs --owner root:${configs_owner#*:} --perms 2775 $dirs_system_space #[what] custom group + setgid, chmod sets mode (umask moot)
mk_dirs --perms 1777 $dirs_system_space_world                          #[what] sticky world-writable, chmod sets mode (umask moot)
