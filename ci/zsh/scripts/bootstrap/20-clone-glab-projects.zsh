#!/bin/zsh
#>[what]
#   clone/sync every konradodwrot gitlab project into ~/projects/gitlab
#/[what]

emulate -LR zsh
setopt errexit pipefail
umask 002

autoload -Uz fn-log-msg

##[>] 🤖🤖
root=${HOME}/projects/gitlab

function sync_project {
  local ns=$1 branch=$2 url=$3
  local dest=${root}/${ns}

  if [[ -z $branch ]] branch=main

  if [[ ! -d ${dest}/.git ]] {
    mkdir -p ${dest:h}
    git clone --quiet $url $dest 2> >(grep -v 'cloned an empty repository' >&2)
    fn-log-msg -t 'clone(new)' $dest
    return 0
  }

  git -C $dest fetch --prune origin

  if { ! git -C $dest rev-parse --verify --quiet origin/$branch >/dev/null } {
    fn-log-msg -t 'sync(no-changes)' $dest
    return 0
  }

  if [[ -n "$(git -C $dest status --porcelain)" ]] {
    fn-log-msg -t 'skip(dirty)' $dest
    return 0
  }

  if [[ "$(git -C $dest symbolic-ref --short HEAD)" != $branch ]] git -C $dest switch $branch

  local before=$(git -C $dest rev-parse HEAD)

  if { ! git -C $dest merge --ff-only origin/$branch } {
    fn-log-msg -t 'skip(diverged)' $dest
    return 0
  }

  if [[ "$(git -C $dest rev-parse HEAD)" == $before ]] {
    fn-log-msg -t 'sync(no-changes)' $dest
    return 0
  }

  fn-log-msg -t 'sync(updated)' $dest
}

glab api --paginate \
  "groups/konradodwrot/projects?include_subgroups=true&archived=false" \
  | jq -r '.[] | [.path_with_namespace, .default_branch, .ssh_url_to_repo] | @tsv' \
  | while IFS=$'\t' read -r ns branch url; do
      if { ! sync_project $ns $branch $url } fn-log-msg -t 'sync(fail)' "${root}/${ns}"
    done
##[<] 🤖🤖
