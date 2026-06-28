#!/bin/zsh
#>[what]
#   Load <configs> into system root, mirroring dir structure.
#   <configs>/root: symlinked by default (live, follow repo).
#   *.host.cp: copied (marker stripped), not linked.
#   *.tmpl: rendered by template loader, skipped here.
#/[what]

emulate -LR zsh
setopt errexit dotglob
IFS= #[why] no split on spaces e.g. 'Application Support'
autoload -Uz fn-log-msg fn-backup-before-overwrite
configs=${1:-$HOME/projects/configs}

: ${HOME:?HOME must be set} #[why] dest paths derive from the invoking user's home

if (( EUID != 0 )) { print -u2 "must run as root"; exit 1 }

#[what] repo-relative -> live dest: HOME[/<rest>] -> $HOME[/<rest>], else /<rest>
function to_dest { [[ $1 == HOME || $1 == HOME/* ]] && print -r -- ${HOME}${1#HOME} || print -r -- /$1 }

#[what] copied dests with explicit owner:perms, format 'owner:group mode'
#[why] sole source of owner/perms. root launchd daemons must be root:wheel 0644
typeset -A perms=()
for d ( dir-size-exporter grafana jaeger loki otelcol port-exporter prometheus ) {
  perms[/Library/LaunchDaemons/$d.plist]='root:wheel 0644'
}

pushd "$configs/root"

typeset -a repo_files repo_dirs ex repo_files_ex copy_files
typeset -aU repo_dirs_all

cp_ext='.host.cp'

# 1. git files, classified by ext
ex=( **/*.tmpl **/*${cp_ext} **/.gitkeep ) #[what] excluded from link pass
repo_files=( ${(f)$(git ls-files --exclude-standard)} )
repo_dirs=( ${(u)repo_files:h} )
repo_files_ex=( ${repo_files:|ex} ) #[what] link-pass set
copy_files=( **/*${cp_ext} )        #[what] copy-pass set

#[what] 🤖🤖 every ancestor dir #[why] plain mkdir (no -p) needs each parent made + owned
#[why] from ALL repo files (links + copies) so parents exist for both passes
for dir ( $repo_dirs ) { while [[ $dir == */* ]] { repo_dirs_all+=$dir; dir=$dir:h }; repo_dirs_all+=$dir } #[what] 🤖🤖

# 2. create dirs, parents first #[what] 🤖🤖
home_user=${SUDO_USER:-$(stat -f '%Su' -- $HOME)} #[why] root runs this. HOME-tree dirs belong to invoking user (SUDO_USER), not root
for dir ( ${(o)repo_dirs_all} ) {  #[what] 🤖🤖 (o) sorts parents before children
  ddir=$(to_dest $dir)
  if [[ -d $ddir ]] { continue }
  if [[ $dir == HOME/* ]] {  #[what] 🤖🤖 HOME-tree: made as user (user-owned, no chown), 0750
    (umask 027; sudo -u $home_user mkdir $ddir); fn-log-msg -t mkdir -- $ddir
  } else {
    (umask 022; mkdir $ddir); fn-log-msg -t mkdir -- $ddir  #[what] 🤖🤖 root-tree: 0755, no -p
  }
}

##[>] link pass
for file ( $repo_files_ex ) {
  dest=$(to_dest $file)
  if [[ ${dest:A} != ${file:A} ]] {
    fn-backup-before-overwrite --repo-root $configs $dest  #[what] keep non-repo dest first
    ln -fws ${file:a} $dest ; fn-log-msg -t ln -- $dest
  }
}
##[<] link pass

##[>] copy pass
for file ( $copy_files ) {
  dest=$(to_dest ${file%${cp_ext}}) #[what] strip marker -> live path
  if { ! cmp -s ${file:a} $dest } {
    fn-backup-before-overwrite $dest  #[why] copied dest is never a repo symlink (no --repo-root)
    if [[ ${file%${cp_ext}} == HOME/* ]] { (umask 027; cp ${file:a} $dest) } else { (umask 022; cp ${file:a} $dest) } #[what] 🤖🤖 HOME-tree 0640, root-tree 0644
    fn-log-msg -t cp -- $dest
    if [[ -n ${perms[$dest]} ]] {
      perm=${perms[$dest]}
      chown -- ${perm%% *} $dest; fn-log-msg -t chown -- "${perm%% *} $dest"
      chmod -- ${perm##* } $dest; fn-log-msg -t chmod -- "${perm##* } $dest"
    }
  }
}
##[<] copy pass
popd
