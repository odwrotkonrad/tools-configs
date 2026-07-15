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
  zstyle -s ":completion:${curcontext}" level-2-max m2 || m2=12
  zstyle -s ":completion:${curcontext}" level-3-max m3 || m3=6
  _cd_deep_capshare v1 h1 $m1
  _cd_deep_capshare v2 h2 $m2
  _cd_deep_capshare v3 h3 $m3

  #[what] hidden group is headerless when its level has visibles; when the level is all-hidden it carries the level header instead
  local expl hh1 hh2 hh3
  (( $#v1 )) || hh1='*'
  (( $#v2 )) || hh2='*/*'
  (( $#v3 )) || hh3='*/*/*'
  local -a dv1 dh1 dv2 dh2 dv3 dh3 sv1 sph1 sv2 sph2 sv3 sph3
  sv1=( ${v1/%//} ); sph1=( ${h1/%//} ); _cd_deep_paircols sv1 sph1 dv1 dh1
  sv2=( ${v2/%//} ); sph2=( ${h2/%//} ); _cd_deep_paircols sv2 sph2 dv2 dh2
  sv3=( ${v3/%//} ); sph3=( ${h3/%//} ); _cd_deep_paircols sv3 sph3 dv3 dh3
  (( $#v1 )) && _wanted pwd     expl '*'     compadd -Q -U -S / -V pwd   -d dv1 -a v1
  (( $#h1 )) && _wanted pwd-h   expl "$hh1"  compadd -Q -U -S / -V pwd-h   -d dh1 -a h1
  (( $#v2 )) && _wanted pwd-1   expl '*/*'   compadd -Q -U -S / -V pwd-1   -d dv2 -a v2
  (( $#h2 )) && _wanted pwd-1-h expl "$hh2"  compadd -Q -U -S / -V pwd-1-h -d dh2 -a h2
  (( $#v3 )) && _wanted pwd-2   expl '*/*/*' compadd -Q -U -S / -V pwd-2   -d dv3 -a v3
  (( $#h3 )) && _wanted pwd-2-h expl "$hh3"  compadd -Q -U -S / -V pwd-2-h -d dh3 -a h3

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
  _cd_deep_capshare uv1 uh1 $mu1
  _cd_deep_capshare uv2 uh2 $mu2
  _cd_deep_capshare uv3 uh3 $mu3

  local up_p=${PWD:h:t} up_g=${PWD:h:h:t}
  local uhh1 uhh2 uhh3
  (( $#uv1 )) || uhh1=".. ${up_p}/*"
  (( $#uv2 )) || uhh2=".. ${up_p}/*/*"
  (( $#uv3 )) || uhh3="../.. ${up_g}/*"
  local -a duv1 duh1 duv2 duh2 duv3 duh3 suv1 suh1 suv2 suh2 suv3 suh3
  suv1=( ${uv1/%//} ); suh1=( ${uh1/%//} ); _cd_deep_paircols suv1 suh1 duv1 duh1
  suv2=( ${uv2/%//} ); suh2=( ${uh2/%//} ); _cd_deep_paircols suv2 suh2 duv2 duh2
  suv3=( ${uv3/%//} ); suh3=( ${uh3/%//} ); _cd_deep_paircols suv3 suh3 duv3 duh3
  (( $#uv1 )) && _wanted up-1   expl ".. ${up_p}/*"    compadd -Q -U -S / -V up-1   -d duv1 -a uv1
  (( $#uh1 )) && _wanted up-1-h expl "$uhh1"   compadd -Q -U -S / -V up-1-h -d duh1 -a uh1
  (( $#uv2 )) && _wanted up-2   expl ".. ${up_p}/*/*"  compadd -Q -U -S / -V up-2   -d duv2 -a uv2
  (( $#uh2 )) && _wanted up-2-h expl "$uhh2"   compadd -Q -U -S / -V up-2-h -d duh2 -a uh2
  (( $#uv3 )) && _wanted up-3   expl "../.. ${up_g}/*" compadd -Q -U -S / -V up-3   -d duv3 -a uv3
  (( $#uh3 )) && _wanted up-3-h expl "$uhh3"   compadd -Q -U -S / -V up-3-h -d duh3 -a uh3

  local -a stack=( $dirstack )                                         #[what] $dirstack = stack minus $PWD
  (( plen )) && stack=( ${(f)"$(_cd_deep_filter $PREFIX $stack)"} )
  stack=( ${(D)stack} )
  local -a dstack=( ${stack/%//} )
  (( $#stack )) && _wanted directory-stack expl 'Stack *' compadd -Q -U -S / -V dstack -d dstack -a stack

  #[what] children/grandchildren of the already-pattern-matched stacked dirs, re-filtered by the typed pattern
  local d
  local -a s1 s2 allstack=( $dirstack )
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
  _cd_deep_capshare sv1 sh1 $ms1
  _cd_deep_capshare sv2 sh2 $ms2

  sv1=( ${(D)sv1} ); sh1=( ${(D)sh1} ); sv2=( ${(D)sv2} ); sh2=( ${(D)sh2} )

  local shh1 shh2
  (( $#sv1 )) || shh1='Stack */*'
  (( $#sv2 )) || shh2='Stack */*/*'
  local -a dsv1 dsh1 dsv2 dsh2 psv1 psh1 psv2 psh2
  psv1=( ${sv1/%//} ); psh1=( ${sh1/%//} ); _cd_deep_paircols psv1 psh1 dsv1 dsh1
  psv2=( ${sv2/%//} ); psh2=( ${sh2/%//} ); _cd_deep_paircols psv2 psh2 dsv2 dsh2
  (( $#sv1 )) && _wanted directory-stack-1   expl 'Stack */*'   compadd -Q -U -S / -V dstack-1   -d dsv1 -a sv1
  (( $#sh1 )) && _wanted directory-stack-1-h expl "$shh1" compadd -Q -U -S / -V dstack-1-h -d dsh1 -a sh1
  (( $#sv2 )) && _wanted directory-stack-2   expl 'Stack */*/*' compadd -Q -U -S / -V dstack-2   -d dsv2 -a sv2
  (( $#sh2 )) && _wanted directory-stack-2-h expl "$shh2" compadd -Q -U -S / -V dstack-2-h -d dsh2 -a sh2

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

##[>] 🤖🤖
#[what] right-pad all four arrays' display strings to their shared max width, so a visible/hidden quad under one heading lays out on the same grid
_cd_deep_quadcols() {
  local -a src1=( ${(P)1} ) src2=( ${(P)2} ) src3=( ${(P)3} ) src4=( ${(P)4} )
  local w=0 x
  for x in $src1 $src2 $src3 $src4; do (( ${#x} > w )) && w=${#x}; done
  local -a d1 d2 d3 d4
  for x in $src1; do d1+=( ${(r:w:)x} ); done
  for x in $src2; do d2+=( ${(r:w:)x} ); done
  for x in $src3; do d3+=( ${(r:w:)x} ); done
  for x in $src4; do d4+=( ${(r:w:)x} ); done
  set -A $5 "${d1[@]}"
  set -A $6 "${d2[@]}"
  set -A $7 "${d3[@]}"
  set -A $8 "${d4[@]}"
}
##[<] 🤖🤖

##[>] 🤖🤖
#[what] visible ($1) and hidden ($2) share cap $3: visible first, hidden fills the remainder, none left -> no hidden; $3<=0 uncapped
_cd_deep_capshare() {
  local m=$3
  (( m <= 0 )) && return
  local -a vis=( ${(P)1} ) hid=( ${(P)2} )
  (( $#vis > m )) && vis=( $vis[1,m] )
  local rest=$(( m - $#vis ))
  if (( rest > 0 )) {
    (( $#hid > rest )) && hid=( $hid[1,rest] )
  } else {
    hid=( )
  }
  set -A $1 "${vis[@]}"
  set -A $2 "${hid[@]}"
}
##[<] 🤖🤖

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
zstyle ':completion:*:cd:*' level-2-max 12
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

##[>] 🤖🤖 file args: PWD / PWD+1 / PWD+2 / PWD+3 / ../* / ../*/* / ../*/*/* / ../../* / dir-stack+1 / dir-stack+2, leaf globs regular files (dirs excluded), per-segment ordered + capped, visible then headerless-hidden groups
_file_deep() {
  local -a lowprec
  zstyle -a ":completion:${curcontext}" low-precedence lowprec

  local plen=$#PREFIX

  local -a l1 l2 l3 l4
  l1=( *(-.omDN) )
  l2=( */*(-.omDN) )
  l3=( */*/*(-.omDN) )
  l4=( */*/*/*(-.omDN) )
  if (( plen )) {
    l1=( ${(f)"$(_cd_deep_filter $PREFIX $l1)"} )
    l2=( ${(f)"$(_cd_deep_filter $PREFIX $l2)"} )
    l3=( ${(f)"$(_cd_deep_filter $PREFIX $l3)"} )
    l4=( ${(f)"$(_cd_deep_filter $PREFIX $l4)"} )
  }

  #[what] each level splits into visible (vN) then hidden (hN) at the '--' delimiter emitted by _file_deep_order
  local -a v1 v2 v3 v4 h1 h2 h3 h4 ordered
  ordered=( ${(f)"$(_file_deep_order $l1)"} ); v1=( ${ordered[1,${ordered[(i)--]}-1]} ); h1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $l2)"} ); v2=( ${ordered[1,${ordered[(i)--]}-1]} ); h2=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $l3)"} ); v3=( ${ordered[1,${ordered[(i)--]}-1]} ); h3=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $l4)"} ); v4=( ${ordered[1,${ordered[(i)--]}-1]} ); h4=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local m1 m2 m3 m4
  zstyle -s ":completion:${curcontext}" level-1-max m1 || m1=0
  zstyle -s ":completion:${curcontext}" level-2-max m2 || m2=12
  zstyle -s ":completion:${curcontext}" level-3-max m3 || m3=6
  zstyle -s ":completion:${curcontext}" level-4-max m4 || m4=6
  _cd_deep_capshare v1 h1 $m1
  _cd_deep_capshare v2 h2 $m2
  _cd_deep_capshare v3 h3 $m3
  _cd_deep_capshare v4 h4 $m4

  #[what] hidden group is headerless when its level has visibles; when the level is all-hidden it carries the level header instead
  local expl hh1 hh2 hh3 hh4
  (( $#v1 )) || hh1='*'
  (( $#v2 )) || hh2='*/*'
  (( $#v3 )) || hh3='*/*/*'
  (( $#v4 )) || hh4='*/*/*/*'
  local -a dv1 dh1 dv2 dh2 dv3 dh3 dv4 dh4
  _cd_deep_paircols v1 h1 dv1 dh1
  _cd_deep_paircols v2 h2 dv2 dh2
  _cd_deep_paircols v3 h3 dv3 dh3
  _cd_deep_paircols v4 h4 dv4 dh4
  (( $#v1 )) && _wanted pwd     expl '*'       compadd -Q -U -V pwd     -d dv1 -a v1
  (( $#h1 )) && _wanted pwd-h   expl "$hh1"    compadd -Q -U -V pwd-h   -d dh1 -a h1
  (( $#v2 )) && _wanted pwd-1   expl '*/*'     compadd -Q -U -V pwd-1   -d dv2 -a v2
  (( $#h2 )) && _wanted pwd-1-h expl "$hh2"    compadd -Q -U -V pwd-1-h -d dh2 -a h2
  (( $#v3 )) && _wanted pwd-2   expl '*/*/*'   compadd -Q -U -V pwd-2   -d dv3 -a v3
  (( $#h3 )) && _wanted pwd-2-h expl "$hh3"    compadd -Q -U -V pwd-2-h -d dh3 -a h3
  (( $#v4 )) && _wanted pwd-3   expl '*/*/*/*' compadd -Q -U -V pwd-3   -d dv4 -a v4
  (( $#h4 )) && _wanted pwd-3-h expl "$hh4"    compadd -Q -U -V pwd-3-h -d dh4 -a h4

  #[what] relative-up groups: siblings (../*), siblings' children (../*/*), grandparent children (../../*); each drops the entry that duplicates PWD / its files / the parent; always globbed, filtered only when a pattern is typed
  local -a u1 u2 u3 u4
  u1=( ../*(-.omDN) );    u1=( ${u1:#../${PWD:t}} )
  u2=( ../*/*(-.omDN) );  u2=( ${u2:#../${PWD:t}/*} )
  u3=( ../../*(-.omDN) ); u3=( ${u3:#../../${PWD:h:t}} )
  u4=( ../*/*/*(-.omDN) ); u4=( ${u4:#../${PWD:t}/*/*} )
  if (( plen )) {
    u1=( ${(f)"$(_cd_deep_filter $PREFIX $u1)"} )
    u2=( ${(f)"$(_cd_deep_filter $PREFIX $u2)"} )
    u3=( ${(f)"$(_cd_deep_filter $PREFIX $u3)"} )
    u4=( ${(f)"$(_cd_deep_filter $PREFIX $u4)"} )
  }

  local -a uv1 uh1 uv2 uh2 uv3 uh3 uv4 uh4
  ordered=( ${(f)"$(_file_deep_order $u1)"} ); uv1=( ${ordered[1,${ordered[(i)--]}-1]} ); uh1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $u2)"} ); uv2=( ${ordered[1,${ordered[(i)--]}-1]} ); uh2=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $u3)"} ); uv3=( ${ordered[1,${ordered[(i)--]}-1]} ); uh3=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $u4)"} ); uv4=( ${ordered[1,${ordered[(i)--]}-1]} ); uh4=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local mu1 mu2 mu3 mu4
  zstyle -s ":completion:${curcontext}" up-1-max mu1 || mu1=6
  zstyle -s ":completion:${curcontext}" up-2-max mu2 || mu2=6
  zstyle -s ":completion:${curcontext}" up-3-max mu3 || mu3=6
  zstyle -s ":completion:${curcontext}" up-4-max mu4 || mu4=6
  _cd_deep_capshare uv1 uh1 $mu1
  _cd_deep_capshare uv2 uh2 $mu2
  _cd_deep_capshare uv3 uh3 $mu3
  _cd_deep_capshare uv4 uh4 $mu4

  local up_p=${PWD:h:t} up_g=${PWD:h:h:t}
  local uhh1 uhh2 uhh3 uhh4
  (( $#uv1 )) || uhh1=".. ${up_p}/*"
  (( $#uv2 )) || uhh2=".. ${up_p}/*/*"
  (( $#uv3 )) || uhh3="../.. ${up_g}/*"
  (( $#uv4 )) || uhh4=".. ${up_p}/*/*/*"
  local -a duv1 duh1 duv2 duh2 duv3 duh3 duv4 duh4
  _cd_deep_paircols uv1 uh1 duv1 duh1
  _cd_deep_paircols uv2 uh2 duv2 duh2
  _cd_deep_paircols uv3 uh3 duv3 duh3
  _cd_deep_paircols uv4 uh4 duv4 duh4
  (( $#uv1 )) && _wanted up-1   expl ".. ${up_p}/*"    compadd -Q -U -V up-1   -d duv1 -a uv1
  (( $#uh1 )) && _wanted up-1-h expl "$uhh1"   compadd -Q -U -V up-1-h -d duh1 -a uh1
  (( $#uv2 )) && _wanted up-2   expl ".. ${up_p}/*/*"  compadd -Q -U -V up-2   -d duv2 -a uv2
  (( $#uh2 )) && _wanted up-2-h expl "$uhh2"   compadd -Q -U -V up-2-h -d duh2 -a uh2
  (( $#uv3 )) && _wanted up-3   expl "../.. ${up_g}/*" compadd -Q -U -V up-3   -d duv3 -a uv3
  (( $#uh3 )) && _wanted up-3-h expl "$uhh3"   compadd -Q -U -V up-3-h -d duh3 -a uh3
  (( $#uv4 )) && _wanted up-4   expl ".. ${up_p}/*/*/*" compadd -Q -U -V up-4   -d duv4 -a uv4
  (( $#uh4 )) && _wanted up-4-h expl "$uhh4"   compadd -Q -U -V up-4-h -d duh4 -a uh4

  #[what] files under the already-pattern-matched stacked dirs, re-filtered by the typed pattern; the bare stacked dir itself is not a valid file arg, so no base Stack group
  local d
  local -a s1 s2 allstack=( $dirstack )
  if (( plen )) {
    for d in $allstack; do s1+=( ${d%/}/*(-.omDN) ); done
    for d in $allstack; do s2+=( ${d%/}/*/*(-.omDN) ); done
    s1=( ${(f)"$(_cd_deep_filter $PREFIX $s1)"} )
    s2=( ${(f)"$(_cd_deep_filter $PREFIX $s2)"} )
  }

  local -a sv1 sh1 sv2 sh2
  ordered=( ${(f)"$(_file_deep_order $s1)"} ); sv1=( ${ordered[1,${ordered[(i)--]}-1]} ); sh1=( ${ordered[${ordered[(i)--]}+1,-1]} )
  ordered=( ${(f)"$(_file_deep_order $s2)"} ); sv2=( ${ordered[1,${ordered[(i)--]}-1]} ); sh2=( ${ordered[${ordered[(i)--]}+1,-1]} )

  local ms1 ms2
  zstyle -s ":completion:${curcontext}" stack-1-max ms1 || ms1=6
  zstyle -s ":completion:${curcontext}" stack-2-max ms2 || ms2=6
  _cd_deep_capshare sv1 sh1 $ms1
  _cd_deep_capshare sv2 sh2 $ms2

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

#[what] partition a leaf-file list (already mtime newest-first from the glob) into visible then a lone '--' delimiter then hidden+low-prec, order preserved; low-prec = a path segment matches low-precedence zstyle
_file_deep_order() {
  local -a files=( "$@" )
  local -a normal hidden lowp
  local p seg hit
  for p in $files; do
    hit=0
    for seg in ${(s:/:)p}; do
      if (( ${lowprec[(I)$seg]} )) { hit=1; break }
    done
    if (( hit )) { lowp+=( $p ); continue }
    if [[ $p == (*/|).[^/]##(|/*) ]] { hidden+=( $p ); continue }
    normal+=( $p )
  done
  print -l -- $normal -- $hidden $lowp
}

zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' low-precedence '.git' 'node_modules' '.cache'
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' level-1-max 0
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' level-2-max 12
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' level-3-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' level-4-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' stack-1-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' stack-2-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' up-1-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' up-2-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' up-3-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' up-4-max 6
zstyle ':completion:*:*:(vim|vi|nano|cat|less|bat):*' group-order \
  pwd pwd-h pwd-1 pwd-1-h pwd-2 pwd-2-h pwd-3 pwd-3-h \
  up-1 up-1-h up-2 up-2-h up-3 up-3-h up-4 up-4-h \
  directory-stack-1 directory-stack-1-h directory-stack-2 directory-stack-2-h
##[<] 🤖🤖

##[>] 🤖🤖 both args (code ls stat): same sources/order/caps as _file_deep, leaf = file OR dir; dirs by item-count desc (trailing /, -S /) first, then files by mtime
#[what] order a level's file glob (mtime) and dir glob (count-desc) each by its native criterion, splice dirs-first into one visible and one hidden tagged stream, capshare the pair together, split back into dir/file visible+hidden preserving order and stripping the kind tag
_both_deep_order() {
  local files_v=$1 dirs_v=$2 cap=$3
  local -a fo do fv fh dv dh
  fo=( ${(f)"$(_file_deep_order ${(P)files_v})"} ); fv=( ${fo[1,${fo[(i)--]}-1]} ); fh=( ${fo[${fo[(i)--]}+1,-1]} )
  do=( ${(f)"$(_cd_deep_order ${(P)dirs_v})"} );    dv=( ${do[1,${do[(i)--]}-1]} ); dh=( ${do[${do[(i)--]}+1,-1]} )

  local -a mvis mhid
  mvis=( ${dv/#/d:} ${fv/#/f:} ); mhid=( ${dh/#/d:} ${fh/#/f:} )
  _cd_deep_capshare mvis mhid $cap

  local e
  local -a odv ofv odh ofh
  for e in $mvis; do [[ $e == d:* ]] && odv+=( ${e#d:} ) || ofv+=( ${e#f:} ); done
  for e in $mhid; do [[ $e == d:* ]] && odh+=( ${e#d:} ) || ofh+=( ${e#f:} ); done
  set -A $dirs_v "${odv[@]}"; set -A ${dirs_v}h "${odh[@]}"
  set -A $files_v "${ofv[@]}"; set -A ${files_v}h "${ofh[@]}"
}

#[what] emit one level: dirs (with trailing-/ display and -S / insert) then files under the shared visible -V tag, then the same under the hidden -V tag; when a stream mixes kinds the two compadds under one -V merge into one visual group
_both_deep_emit() {
  local files_v=$1 dirs_v=$2 vtag=$3 htag=$4 vhdr=$5 hhdr=$6
  local files_vh=${files_v}h dirs_vh=${dirs_v}h
  local -a fv=( ${(P)files_v} ) dv=( ${(P)dirs_v} )
  local -a fh=( ${(P)files_vh} ) dh=( ${(P)dirs_vh} )
  local expl
  local -a ddv dfv ddh dfh pddv pdfv pddh pdfh
  ddv=( ${dv/%//} ); dfv=( $fv ); ddh=( ${dh/%//} ); dfh=( $fh )
  _cd_deep_quadcols ddv dfv ddh dfh  pddv pdfv pddh pdfh
  (( $#dv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vtag -S / -d pddv -a dv }
  (( $#fv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vtag        -d pdfv -a fv }
  (( $#dh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $htag -S / -d pddh -a dh }
  (( $#fh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $htag        -d pdfh -a fh }
}

_both_deep() {
  local -a lowprec deprio
  zstyle -a ":completion:${curcontext}" low-precedence lowprec
  zstyle -a ":completion:${curcontext}" deprioritize-name deprio
  (( $#deprio )) || deprio=( test )

  local plen=$#PREFIX

  #[what] two parallel globs per level: files *(-.omDN) mtime-newest-first, dirs *(-/DN); ordered/spliced/capped together by _both_deep_order into <name> (visible) + <name>h (hidden)
  local -a lf1 lf2 lf3 lf4 ld1 ld2 ld3 ld4
  lf1=( *(-.omDN) );       ld1=( *(-/DN) )
  lf2=( */*(-.omDN) );     ld2=( */*(-/DN) )
  lf3=( */*/*(-.omDN) );   ld3=( */*/*(-/DN) )
  lf4=( */*/*/*(-.omDN) ); ld4=( */*/*/*(-/DN) )
  if (( plen )) {
    lf1=( ${(f)"$(_cd_deep_filter $PREFIX $lf1)"} ); ld1=( ${(f)"$(_cd_deep_filter $PREFIX $ld1)"} )
    lf2=( ${(f)"$(_cd_deep_filter $PREFIX $lf2)"} ); ld2=( ${(f)"$(_cd_deep_filter $PREFIX $ld2)"} )
    lf3=( ${(f)"$(_cd_deep_filter $PREFIX $lf3)"} ); ld3=( ${(f)"$(_cd_deep_filter $PREFIX $ld3)"} )
    lf4=( ${(f)"$(_cd_deep_filter $PREFIX $lf4)"} ); ld4=( ${(f)"$(_cd_deep_filter $PREFIX $ld4)"} )
  }

  local m1 m2 m3 m4
  zstyle -s ":completion:${curcontext}" level-1-max m1 || m1=0
  zstyle -s ":completion:${curcontext}" level-2-max m2 || m2=12
  zstyle -s ":completion:${curcontext}" level-3-max m3 || m3=6
  zstyle -s ":completion:${curcontext}" level-4-max m4 || m4=6
  local -a lf1h lf2h lf3h lf4h ld1h ld2h ld3h ld4h
  _both_deep_order lf1 ld1 $m1
  _both_deep_order lf2 ld2 $m2
  _both_deep_order lf3 ld3 $m3
  _both_deep_order lf4 ld4 $m4

  local hh1 hh2 hh3 hh4
  (( $#lf1 + $#ld1 )) || hh1='*'
  (( $#lf2 + $#ld2 )) || hh2='*/*'
  (( $#lf3 + $#ld3 )) || hh3='*/*/*'
  (( $#lf4 + $#ld4 )) || hh4='*/*/*/*'
  _both_deep_emit lf1 ld1 pwd   pwd-h   '*'       "$hh1"
  _both_deep_emit lf2 ld2 pwd-1 pwd-1-h '*/*'     "$hh2"
  _both_deep_emit lf3 ld3 pwd-2 pwd-2-h '*/*/*'   "$hh3"
  _both_deep_emit lf4 ld4 pwd-3 pwd-3-h '*/*/*/*' "$hh4"

  #[what] relative-up groups: siblings (../*), siblings' children (../*/*), grandparent children (../../*), parent great-grandchildren (../*/*/*); each drops the entry duplicating PWD / its children / the parent; both kinds per group
  local -a uf1 uf2 uf3 uf4 ud1 ud2 ud3 ud4
  uf1=( ../*(-.omDN) );     uf1=( ${uf1:#../${PWD:t}} )
  uf2=( ../*/*(-.omDN) );   uf2=( ${uf2:#../${PWD:t}/*} )
  uf3=( ../../*(-.omDN) );  uf3=( ${uf3:#../../${PWD:h:t}} )
  uf4=( ../*/*/*(-.omDN) ); uf4=( ${uf4:#../${PWD:t}/*/*} )
  ud1=( ../*(-/DN) );       ud1=( ${ud1:#../${PWD:t}} )
  ud2=( ../*/*(-/DN) );     ud2=( ${ud2:#../${PWD:t}/*} )
  ud3=( ../../*(-/DN) );    ud3=( ${ud3:#../../${PWD:h:t}} )
  ud4=( ../*/*/*(-/DN) );   ud4=( ${ud4:#../${PWD:t}/*/*} )
  if (( plen )) {
    uf1=( ${(f)"$(_cd_deep_filter $PREFIX $uf1)"} ); ud1=( ${(f)"$(_cd_deep_filter $PREFIX $ud1)"} )
    uf2=( ${(f)"$(_cd_deep_filter $PREFIX $uf2)"} ); ud2=( ${(f)"$(_cd_deep_filter $PREFIX $ud2)"} )
    uf3=( ${(f)"$(_cd_deep_filter $PREFIX $uf3)"} ); ud3=( ${(f)"$(_cd_deep_filter $PREFIX $ud3)"} )
    uf4=( ${(f)"$(_cd_deep_filter $PREFIX $uf4)"} ); ud4=( ${(f)"$(_cd_deep_filter $PREFIX $ud4)"} )
  }

  local mu1 mu2 mu3 mu4
  zstyle -s ":completion:${curcontext}" up-1-max mu1 || mu1=6
  zstyle -s ":completion:${curcontext}" up-2-max mu2 || mu2=6
  zstyle -s ":completion:${curcontext}" up-3-max mu3 || mu3=6
  zstyle -s ":completion:${curcontext}" up-4-max mu4 || mu4=6
  local -a uf1h uf2h uf3h uf4h ud1h ud2h ud3h ud4h
  _both_deep_order uf1 ud1 $mu1
  _both_deep_order uf2 ud2 $mu2
  _both_deep_order uf3 ud3 $mu3
  _both_deep_order uf4 ud4 $mu4

  local up_p=${PWD:h:t} up_g=${PWD:h:h:t}
  local uhh1 uhh2 uhh3 uhh4
  (( $#uf1 + $#ud1 )) || uhh1=".. ${up_p}/*"
  (( $#uf2 + $#ud2 )) || uhh2=".. ${up_p}/*/*"
  (( $#uf3 + $#ud3 )) || uhh3="../.. ${up_g}/*"
  (( $#uf4 + $#ud4 )) || uhh4=".. ${up_p}/*/*/*"
  _both_deep_emit uf1 ud1 up-1 up-1-h ".. ${up_p}/*"       "$uhh1"
  _both_deep_emit uf2 ud2 up-2 up-2-h ".. ${up_p}/*/*"     "$uhh2"
  _both_deep_emit uf3 ud3 up-3 up-3-h "../.. ${up_g}/*"    "$uhh3"
  _both_deep_emit uf4 ud4 up-4 up-4-h ".. ${up_p}/*/*/*"   "$uhh4"

  #[what] file+dir leaves under the already-pattern-matched stacked dirs, re-filtered by the typed pattern; the bare stacked dir is offered by _cd_deep, not here
  local d
  local -a sf1 sf2 sd1 sd2 allstack=( $dirstack )
  if (( plen )) {
    for d in $allstack; do sf1+=( ${d%/}/*(-.omDN) ); sd1+=( ${d%/}/*(-/DN) ); done
    for d in $allstack; do sf2+=( ${d%/}/*/*(-.omDN) ); sd2+=( ${d%/}/*/*(-/DN) ); done
    sf1=( ${(f)"$(_cd_deep_filter $PREFIX $sf1)"} ); sd1=( ${(f)"$(_cd_deep_filter $PREFIX $sd1)"} )
    sf2=( ${(f)"$(_cd_deep_filter $PREFIX $sf2)"} ); sd2=( ${(f)"$(_cd_deep_filter $PREFIX $sd2)"} )
  }

  local ms1 ms2
  zstyle -s ":completion:${curcontext}" stack-1-max ms1 || ms1=6
  zstyle -s ":completion:${curcontext}" stack-2-max ms2 || ms2=6
  local -a sf1h sf2h sd1h sd2h
  _both_deep_order sf1 sd1 $ms1
  _both_deep_order sf2 sd2 $ms2

  sf1=( ${(D)sf1} ); sf1h=( ${(D)sf1h} ); sd1=( ${(D)sd1} ); sd1h=( ${(D)sd1h} )
  sf2=( ${(D)sf2} ); sf2h=( ${(D)sf2h} ); sd2=( ${(D)sd2} ); sd2h=( ${(D)sd2h} )

  local shh1 shh2
  (( $#sf1 + $#sd1 )) || shh1='Stack */*'
  (( $#sf2 + $#sd2 )) || shh2='Stack */*/*'
  _both_deep_emit sf1 sd1 directory-stack-1 directory-stack-1-h 'Stack */*'   "$shh1"
  _both_deep_emit sf2 sd2 directory-stack-2 directory-stack-2-h 'Stack */*/*' "$shh2"

  (( plen && ${+compstate} && compstate[nmatches] )) && compstate[insert]=menu
}

zstyle ':completion:*:*:(code|ls|stat):*' low-precedence '.git' 'node_modules' '.cache'
zstyle ':completion:*:*:(code|ls|stat):*' deprioritize-name 'test'
zstyle ':completion:*:*:(code|ls|stat):*' level-1-max 0
zstyle ':completion:*:*:(code|ls|stat):*' level-2-max 12
zstyle ':completion:*:*:(code|ls|stat):*' level-3-max 6
zstyle ':completion:*:*:(code|ls|stat):*' level-4-max 6
zstyle ':completion:*:*:(code|ls|stat):*' stack-1-max 6
zstyle ':completion:*:*:(code|ls|stat):*' stack-2-max 6
zstyle ':completion:*:*:(code|ls|stat):*' up-1-max 6
zstyle ':completion:*:*:(code|ls|stat):*' up-2-max 6
zstyle ':completion:*:*:(code|ls|stat):*' up-3-max 6
zstyle ':completion:*:*:(code|ls|stat):*' up-4-max 6
zstyle ':completion:*:*:(code|ls|stat):*' group-order \
  pwd pwd-h pwd-1 pwd-1-h pwd-2 pwd-2-h pwd-3 pwd-3-h \
  up-1 up-1-h up-2 up-2-h up-3 up-3-h up-4 up-4-h \
  directory-stack-1 directory-stack-1-h directory-stack-2 directory-stack-2-h
##[<] 🤖🤖
