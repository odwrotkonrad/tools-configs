#!/usr/bin/env zsh
##[>] 🤖🤖
h=$1
root=$(git -C $1 rev-parse --show-toplevel 2>/dev/null)
[[ $h == $HOME(|/*) ]] && h="~${h#$HOME}"
[[ -n $root && $root == $HOME(|/*) ]] && root="~${root#$HOME}"
segs=( ${(s:/:)h} ) ; n=$#segs
ri=0
[[ -n $root ]] && ri=${#${(s:/:)root}}
out=()
for i in {1..$n}; do
  if (( i > n-2 || i == ri )) || [[ $segs[i] == '~' ]]; then seg=$segs[i]
  else seg=${segs[i][1]}
  fi
  out+=( $seg )
done
[[ $h == /* ]] && out[1]="/$out[1]"
pre=
if [[ -n $root ]]; then
  b=$(git -C $1 branch --show-current 2>/dev/null)
  [[ -n $b ]] && pre=" $b "
  a=0 m=0 d=0
  for l in ${(f)"$(git -C $1 status --porcelain 2>/dev/null)"}; do
    st=${l[1,2]}
    if [[ $st == '??' || $st == A? || $st == ?A ]]; then ((a++))
    elif [[ $st == D? || $st == ?D ]]; then ((d++))
    else ((m++))
    fi
  done
  pre+="(+$a ~$m -$d) "
fi
case $2 in
  (git) print -r -- "$pre" ;;
  (pwd) print -r -- ${(j:/:)out} ;;
  (*) print -r -- "$pre${(j:/:)out}" ;;
esac
##[<] 🤖🤖
