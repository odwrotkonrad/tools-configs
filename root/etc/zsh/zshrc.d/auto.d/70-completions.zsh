zstyle ':completion:*:*:make:*' tag-order 'targets'
zstyle ':completion:*' verbose false  # do not show descriptions
zstyle ':completion:*' menu select    # cycle through options in menu
zstyle ':completion:*' file-sort modification


# if nothing on the left on cursor, start completion instead of insering tab
zstyle ':completion:*' insert-tab false

# categorize different type of matches into groups, e.g files into group, commands into group etc.
zstyle ':completion:*:*:*:*:descriptions' format '%B## %d %b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# generate completions in order stopping at first that generate matches
# 1. smart case matches - lowercase -> case insensitive, otherwise case sensitive
# 2. separator aware smart case matches - f.b -> foo.bar, o.a -> foo.bar
# 3. fuzzy match
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:lower:]}={[:upper:]} l:|=* r:|[._-]=* r:|=*' \
  'r:|?=** m:{[:lower:]}={[:upper:]}'

zstyle ':completion:::::' completer _expand_alias _expand _complete _match _ignored

zstyle ':completion:*' list-dirs-first true

zstyle ':completion:*' use-cache off
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

##[>] 🤖🤖
zstyle ':completion:*:*:touch:argument-1:*' format ''
##[<] 🤖🤖

##[>] 🤖🤖🤖 cd: PWD / PWD+1 / PWD+2 / ../* (siblings, PWD dropped) / ../*/* (siblings' children, PWD's own dropped) / ../../* (grandparent children, parent dropped) / dir-stack / dir-stack+1 / dir-stack+2 ..., per-segment ordered + capped, visible then headerless-hidden groups
_cd_deep() {
  local -a lowprec deprio
  zstyle -a ":completion:${curcontext}" low-precedence lowprec
  zstyle -a ":completion:${curcontext}" deprioritize-name deprio
  (( $#deprio )) || deprio=( test )

  local plen=$#PREFIX

  local -a l1 l2 l3
  l1=( *(-/DN) )
  l2=( */*(-/DN) )
  l3=( */*/*(-/DN) )
  if (( plen )) {
    l1=( ${(f)"$(_cd_deep_filter $PREFIX $l1)"} )
    l2=( ${(f)"$(_cd_deep_filter $PREFIX $l2)"} )
    l3=( ${(f)"$(_cd_deep_filter $PREFIX $l3)"} )
  }

  #[what] each level splits into visible (vN) then hidden (hN) at the '--' delimiter emitted by _cd_deep_order
  local -a v1 v2 v3 h1 h2 h3 ordered
  ordered=( ${(f)"$(_cd_deep_order $l1)"} ); v1=( ${ordered[1,${ordered[(i)--]}-1]} ); h1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_cd_deep_order $l2)"} ); v2=( ${ordered[1,${ordered[(i)--]}-1]} ); h2=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_cd_deep_order $l3)"} ); v3=( ${ordered[1,${ordered[(i)--]}-1]} ); h3=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local m1 m2 m3
  zstyle -s ":completion:${curcontext}" level-1-max m1 || m1=0
  zstyle -s ":completion:${curcontext}" level-2-max m2 || m2=20
  zstyle -s ":completion:${curcontext}" level-3-max m3 || m3=6
  (( m1 > 0 && $#v1 > m1 )) && v1=( $v1[1,m1] )
  (( m1 > 0 && $#h1 > m1 )) && h1=( $h1[1,m1] )
  (( m2 > 0 && $#v2 > m2 )) && v2=( $v2[1,m2] )
  (( m2 > 0 && $#h2 > m2 )) && h2=( $h2[1,m2] )
  (( m3 > 0 && $#v3 > m3 )) && v3=( $v3[1,m3] )
  (( m3 > 0 && $#h3 > m3 )) && h3=( $h3[1,m3] )

  #[what] hidden group is headerless when its level has visibles; when the level is all-hidden it carries the level header instead
  local expl hh1 hh2 hh3
  (( $#v1 )) || hh1='*'
  (( $#v2 )) || hh2='*/*'
  (( $#v3 )) || hh3='*/*/*'
  local -a dv1 dh1 dv2 dh2 dv3 dh3
  _cd_deep_paircols v1 h1 dv1 dh1
  _cd_deep_paircols v2 h2 dv2 dh2
  _cd_deep_paircols v3 h3 dv3 dh3
  (( $#v1 )) && _wanted pwd     expl '*'     compadd -Q -U -V pwd   -d dv1 -a v1
  (( $#h1 )) && _wanted pwd-h   expl "$hh1"  compadd -Q -U -V pwd-h   -d dh1 -a h1
  (( $#v2 )) && _wanted pwd-1   expl '*/*'   compadd -Q -U -V pwd-1   -d dv2 -a v2
  (( $#h2 )) && _wanted pwd-1-h expl "$hh2"  compadd -Q -U -V pwd-1-h -d dh2 -a h2
  (( $#v3 )) && _wanted pwd-2   expl '*/*/*' compadd -Q -U -V pwd-2   -d dv3 -a v3
  (( $#h3 )) && _wanted pwd-2-h expl "$hh3"  compadd -Q -U -V pwd-2-h -d dh3 -a h3

  #[what] relative-up groups: siblings (../*), siblings' children (../*/*), grandparent children (../../*); each drops the entry that duplicates PWD / its children / the parent; always globbed, filtered only when a pattern is typed
  local -a u1 u2 u3
  u1=( ../*(-/DN) );    u1=( ${u1:#../${PWD:t}} )
  u2=( ../*/*(-/DN) );  u2=( ${u2:#../${PWD:t}/*} )
  u3=( ../../*(-/DN) ); u3=( ${u3:#../../${PWD:h:t}} )
  if (( plen )) {
    u1=( ${(f)"$(_cd_deep_filter $PREFIX $u1)"} )
    u2=( ${(f)"$(_cd_deep_filter $PREFIX $u2)"} )
    u3=( ${(f)"$(_cd_deep_filter $PREFIX $u3)"} )
  }

  local -a uv1 uh1 uv2 uh2 uv3 uh3
  ordered=( ${(f)"$(_cd_deep_order $u1)"} ); uv1=( ${ordered[1,${ordered[(i)--]}-1]} ); uh1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_cd_deep_order $u2)"} ); uv2=( ${ordered[1,${ordered[(i)--]}-1]} ); uh2=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_cd_deep_order $u3)"} ); uv3=( ${ordered[1,${ordered[(i)--]}-1]} ); uh3=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local mu1 mu2 mu3
  zstyle -s ":completion:${curcontext}" up-1-max mu1 || mu1=6
  zstyle -s ":completion:${curcontext}" up-2-max mu2 || mu2=6
  zstyle -s ":completion:${curcontext}" up-3-max mu3 || mu3=6
  (( mu1 > 0 && $#uv1 > mu1 )) && uv1=( $uv1[1,mu1] ); (( mu1 > 0 && $#uh1 > mu1 )) && uh1=( $uh1[1,mu1] )
  (( mu2 > 0 && $#uv2 > mu2 )) && uv2=( $uv2[1,mu2] ); (( mu2 > 0 && $#uh2 > mu2 )) && uh2=( $uh2[1,mu2] )
  (( mu3 > 0 && $#uv3 > mu3 )) && uv3=( $uv3[1,mu3] ); (( mu3 > 0 && $#uh3 > mu3 )) && uh3=( $uh3[1,mu3] )

  local uhh1 uhh2 uhh3
  (( $#uv1 )) || uhh1='../*'
  (( $#uv2 )) || uhh2='../*/*'
  (( $#uv3 )) || uhh3='../../*'
  local -a duv1 duh1 duv2 duh2 duv3 duh3
  _cd_deep_paircols uv1 uh1 duv1 duh1
  _cd_deep_paircols uv2 uh2 duv2 duh2
  _cd_deep_paircols uv3 uh3 duv3 duh3
  (( $#uv1 )) && _wanted up-1   expl '../*'    compadd -Q -U -V up-1   -d duv1 -a uv1
  (( $#uh1 )) && _wanted up-1-h expl "$uhh1"   compadd -Q -U -V up-1-h -d duh1 -a uh1
  (( $#uv2 )) && _wanted up-2   expl '../*/*'  compadd -Q -U -V up-2   -d duv2 -a uv2
  (( $#uh2 )) && _wanted up-2-h expl "$uhh2"   compadd -Q -U -V up-2-h -d duh2 -a uh2
  (( $#uv3 )) && _wanted up-3   expl '../../*' compadd -Q -U -V up-3   -d duv3 -a uv3
  (( $#uh3 )) && _wanted up-3-h expl "$uhh3"   compadd -Q -U -V up-3-h -d duh3 -a uh3

  local -a stack=( $dirstack )                                         #[what] $dirstack = stack minus $PWD
  (( plen )) && stack=( ${(f)"$(_cd_deep_filter $PREFIX $stack)"} )
  stack=( ${(D)stack} )
  (( $#stack )) && _wanted directory-stack expl 'Stack *' compadd -Q -U -V dstack -a stack

  #[what] children/grandchildren of the already-pattern-matched stacked dirs, re-filtered by the typed pattern
  local d
  local -a s1 s2 allstack=( ${(D)dirstack} )
  if (( plen )) {
    for d in $allstack; do s1+=( ${d%/}/*(-/DN) ); done
    for d in $allstack; do s2+=( ${d%/}/*/*(-/DN) ); done
    s1=( ${(f)"$(_cd_deep_filter $PREFIX $s1)"} )
    s2=( ${(f)"$(_cd_deep_filter $PREFIX $s2)"} )
  }

  local -a sv1 sh1 sv2 sh2
  ordered=( ${(f)"$(_cd_deep_order $s1)"} ); sv1=( ${ordered[1,${ordered[(i)--]}-1]} ); sh1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_cd_deep_order $s2)"} ); sv2=( ${ordered[1,${ordered[(i)--]}-1]} ); sh2=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local ms1 ms2
  zstyle -s ":completion:${curcontext}" stack-1-max ms1 || ms1=6
  zstyle -s ":completion:${curcontext}" stack-2-max ms2 || ms2=6
  (( ms1 > 0 && $#sv1 > ms1 )) && sv1=( $sv1[1,ms1] )
  (( ms1 > 0 && $#sh1 > ms1 )) && sh1=( $sh1[1,ms1] )
  (( ms2 > 0 && $#sv2 > ms2 )) && sv2=( $sv2[1,ms2] )
  (( ms2 > 0 && $#sh2 > ms2 )) && sh2=( $sh2[1,ms2] )

  sv1=( ${(D)sv1} ); sh1=( ${(D)sh1} ); sv2=( ${(D)sv2} ); sh2=( ${(D)sh2} )

  local shh1 shh2
  (( $#sv1 )) || shh1='Stack */*'
  (( $#sv2 )) || shh2='Stack */*/*'
  local -a dsv1 dsh1 dsv2 dsh2
  _cd_deep_paircols sv1 sh1 dsv1 dsh1
  _cd_deep_paircols sv2 sh2 dsv2 dsh2
  (( $#sv1 )) && _wanted directory-stack-1   expl 'Stack */*'   compadd -Q -U -V dstack-1   -d dsv1 -a sv1
  (( $#sh1 )) && _wanted directory-stack-1-h expl "$shh1" compadd -Q -U -V dstack-1-h -d dsh1 -a sh1
  (( $#sv2 )) && _wanted directory-stack-2   expl 'Stack */*/*' compadd -Q -U -V dstack-2   -d dsv2 -a sv2
  (( $#sh2 )) && _wanted directory-stack-2-h expl "$shh2" compadd -Q -U -V dstack-2-h -d dsh2 -a sh2

  (( plen && ${+compstate} && compstate[nmatches] )) && compstate[insert]=menu
}

#[what] keep paths whose segments fuzzy-match the pattern segments in typed order, last pattern segment anchored to the path's deepest segment
_cd_deep_filter() {
  local pat=$1; shift
  local -a pseg=( ${(s:/:)pat} )
  local np=$#pseg
  local p pi si ok
  local -a ps
  for p in "$@"; do
    ps=( ${(s:/:)p} )
    (( np > $#ps )) && continue
    _cd_deep_fuzzy $pseg[np] $ps[$#ps] || continue
    if (( np > 1 )) {
      pi=1; si=1
      while (( pi < np && si < $#ps )); do
        _cd_deep_fuzzy $pseg[pi] $ps[si] && (( pi++ ))
        (( si++ ))
      done
      (( pi == np )) || continue
    }
    print -r -- $p
  done
}

#[what] all chars of $1 appear in order in $2, case-insensitive
_cd_deep_fuzzy() {
  local -a chars=( ${(s::)1} )
  local c pi=1
  for c in ${(s::)2}; do
    (( pi > $#chars )) && break
    [[ ${(L)c} == ${(L)chars[pi]} ]] && (( pi++ ))
  done
  (( pi > $#chars ))
}

#[what] partition a dir list into two count-desc streams: visible (normal+deprio) then a lone '--' delimiter line then hidden (hidden dirs + low-prec), each by item-count desc; '--' after print's own '--' so an empty visible stream keeps the delimiter
_cd_deep_order() {
  local -a dirs=( "$@" ) items
  local -a normal deprioed hidden lowp
  local p base seg n hit
  for p in $dirs; do
    local -a items=( $p/*(ND) )
    n=$#items
    hit=0
    for seg in ${(s:/:)p}; do
      if (( ${lowprec[(I)$seg]} )) { hit=1; break }
    done
    if (( hit )) { lowp+=( "$n $p" ); continue }
    if [[ $p == (*/|).[^/]##(|/*) ]] { hidden+=( "$n $p" ); continue }
    base=${p:t}; hit=0
    for seg in $deprio; do
      if [[ ${(L)base} == *${(L)seg}* ]] { hit=1; break }
    done
    if (( hit )) { deprioed+=( "$n $p" ); continue }
    normal+=( "$n $p" )
  done
  normal=( ${(On)normal} ); deprioed=( ${(On)deprioed} )
  hidden=( ${(On)hidden} ); lowp=( ${(On)lowp} )
  print -l -- ${normal#* } ${deprioed#* } -- ${hidden#* } ${lowp#* }
}

#[what] right-pad both arrays' display strings to their shared max width, so a visible/hidden pair lays out in the same (lower) column count
_cd_deep_paircols() {
  local -a src1=( ${(P)1} ) src2=( ${(P)2} )
  local w=0 x
  for x in $src1 $src2; do (( ${#x} > w )) && w=${#x}; done
  local -a d1 d2
  for x in $src1; do d1+=( ${(r:w:)x} ); done
  for x in $src2; do d2+=( ${(r:w:)x} ); done
  set -A $3 "${d1[@]}"
  set -A $4 "${d2[@]}"
}

#[what] home-aware, tail-2-full path: HOME->~, all but the last two segments shrunk to their first char
_cd_deep_shortpwd() {
  local h=${(D)1} ; local -a segs=( ${(s:/:)h} ) ; local n=$#segs
  (( n <= 2 )) && { print -r -- $h; return }
  local -a out ; local i
  for i in {1..$n}; do
    if (( i > n-2 )); then out+=( $segs[i] )
    elif [[ $segs[i] == '~' ]]; then out+=( '~' )
    else out+=( ${segs[i][1]} )
    fi
  done
  print -r -- ${(j:/:)out}
}

zstyle ':completion:*:cd:*' low-precedence '.git' 'node_modules' '.cache'
zstyle ':completion:*:cd:*' deprioritize-name 'test'
zstyle ':completion:*:cd:*' level-1-max 0
zstyle ':completion:*:cd:*' level-2-max 10
zstyle ':completion:*:cd:*' level-3-max 6
zstyle ':completion:*:cd:*' stack-1-max 6
zstyle ':completion:*:cd:*' stack-2-max 6
zstyle ':completion:*:cd:*' up-1-max 6
zstyle ':completion:*:cd:*' up-2-max 6
zstyle ':completion:*:cd:*' up-3-max 6
zstyle ':completion:*:cd:*' group-order \
  pwd pwd-h pwd-1 pwd-1-h pwd-2 pwd-2-h \
  up-1 up-1-h up-2 up-2-h up-3 up-3-h \
  directory-stack directory-stack-1 directory-stack-1-h directory-stack-2 directory-stack-2-h
##[<] 🤖🤖
