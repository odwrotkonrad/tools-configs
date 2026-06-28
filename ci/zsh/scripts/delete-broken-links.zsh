#!/bin/zsh
#>[what]
#   collect dirs from last 10 commits, find broken links, remove them
#/[what]

emulate -LR zsh
setopt errexit dotglob
IFS=
autoload -Uz fn-log-msg
configs=${1:-$HOME/projects/configs}

: ${HOME:?HOME must be set}

function delete_broken_links {
  local root=$1 ; fn-log-msg -t delete-broken-links -- $root

  typeset -aU dirs broken
  # 1. 10 last refs -> dirs
  for ref ( ${(@f)$(git rev-list -10 HEAD)} ) {
    dirs+=( ${(@f)$(git ls-tree -dr --name-only $ref)} )
  }

  # 2. dirs -> dirs with >=2 parts #[why] reduce search radius
  dirs=( ${(M)dirs:#*/?*} ) #[what] (M) keep matches, path with non-trailing slash

  # 3. dirs -> OS dirs; HOME/<rest> -> $HOME/<rest>, else /<rest>
  local -a os_dirs
  for dir ( $dirs ) {
    [[ $dir == HOME/* ]] && os_dirs+=( $HOME/${dir#HOME/} ) || os_dirs+=( /$dir )
  }
  dirs=( $os_dirs )

  # 4. dirs -> broken links (ignore *.bk backups)
  for dir ( $dirs ) {
    broken+=( $dir/*(-@N) )
  }
  broken=( ${broken:#*.bk} )

  # 5. broken links -> rm
  if (( $#broken )) { rm $broken ; fn-log-msg -t rm -- ${(j: :)broken} }
}

pushd $configs/root
delete_broken_links root
popd
