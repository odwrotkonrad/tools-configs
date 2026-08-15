#!/usr/bin/env zsh
##[>] 🤖🤖
src=$1
mode=$2
git_root=$(git -C $src rev-parse --show-toplevel 2>/dev/null)
dir=$src
[[ $dir == $HOME(|/*) ]] && dir="~${dir#$HOME}"
[[ -n $git_root && $git_root == $HOME(|/*) ]] && git_root="~${git_root#$HOME}"
segments=( ${(s:/:)dir} ) ; seg_count=$#segments
git_root_depth=0
[[ -n $git_root ]] && git_root_depth=${#${(s:/:)git_root}}
short_segs=()
for i in {1..$seg_count}; do
  if (( i > seg_count-2 || i == git_root_depth )) || [[ $segments[i] == '~' ]]; then seg=$segments[i]
  else seg=${segments[i][1]}
  fi
  short_segs+=( $seg )
done
[[ $dir == /* ]] && short_segs[1]="/$short_segs[1]"
git_info=
if [[ -n $git_root ]]; then
  branch=$(git -C $src branch --show-current 2>/dev/null)
  [[ -n $branch ]] && git_info=" $branch "
  added=0 modified=0 deleted=0
  for line in ${(f)"$(git -C $src status --porcelain 2>/dev/null)"}; do
    code=${line[1,2]}
    if [[ $code == '??' || $code == A? || $code == ?A ]]; then ((added++))
    elif [[ $code == D? || $code == ?D ]]; then ((deleted++))
    else ((modified++))
    fi
  done
  git_info+="(+$added ~$modified -$deleted) "
fi
case $mode in
  (git) print -r -- "$git_info" ;;
  (pwd) print -r -- ${(j:/:)short_segs} ;;
  (*) print -r -- "$git_info${(j:/:)short_segs}" ;;
esac
##[<] 🤖🤖
