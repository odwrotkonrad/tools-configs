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

##[>] 🤖🤖🤖 one engine drives cd/vim/code deep-path completion; kind (dirs|files|both) + zstyles (levels, up-levels, base-stack, per-segment caps, low-precedence, deprioritize-name) are its only axes
#[what] glob qualifier per kind: dirs count-desc, files mtime-newest-first; both globs each stream in parallel
_deep_qual_files='(-.omDN)'
_deep_qual_dirs='(-/DN)'

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
#[what] vtag/htag are the completion tags (_wanted, tag-order); vgrp/hgrp are the -V group names (visual grouping, group-order); default vgrp=vtag hgrp=htag so single-name callers pass four args
_both_deep_emit() {
  local files_v=$1 dirs_v=$2 vtag=$3 htag=$4 vhdr=$5 hhdr=$6 vgrp=${7:-$3} hgrp=${8:-$4}
  local files_vh=${files_v}h dirs_vh=${dirs_v}h
  local -a fv=( ${(P)files_v} ) dv=( ${(P)dirs_v} )
  local -a fh=( ${(P)files_vh} ) dh=( ${(P)dirs_vh} )
  local expl
  local -a ddv dfv ddh dfh pddv pdfv pddh pdfh
  ddv=( ${dv/%//} ); dfv=( $fv ); ddh=( ${dh/%//} ); dfh=( $fh )
  _cd_deep_quadcols ddv dfv ddh dfh  pddv pdfv pddh pdfh
  (( $#dv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vgrp -S / -d pddv -a dv }
  (( $#fv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vgrp        -d pdfv -a fv }
  (( $#dh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $hgrp -S / -d pddh -a dh }
  (( $#fh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $hgrp        -d pdfh -a fh }
}

##[>] 🤖🤖🤖
#[what] deep-path completion engine; kind selects which globs run; a per-kind-empty array reduces the both-machinery to a single-kind capshare/emit, so cd/vim/code share one body
_deep() {
  local kind=$1
  local -a lowprec deprio
  zstyle -a ":completion:${curcontext}" low-precedence lowprec
  zstyle -a ":completion:${curcontext}" deprioritize-name deprio
  (( $#deprio )) || deprio=( test )

  local dofiles=0 dodirs=0
  [[ $kind == files || $kind == both ]] && dofiles=1
  [[ $kind == dirs  || $kind == both ]] && dodirs=1

  local levels uplevels basestack stacktag
  zstyle -s ":completion:${curcontext}" levels levels        || levels=4
  zstyle -s ":completion:${curcontext}" up-levels uplevels   || uplevels=4
  zstyle -s ":completion:${curcontext}" base-stack basestack || basestack=false
  zstyle -s ":completion:${curcontext}" stack-tag stacktag   || stacktag=directory-stack

  local plen=$#PREFIX
  local cap star vtag htag vhdr hhdr fv dv

  #[what] pwd levels 1..levels: glob (*/)^{n-1}*<qual> per kind, filter, order+cap together, emit dirs-with-/ then files
  local i
  for i in {1..$levels}; do
    fv=_deep_f$i; dv=_deep_d$i
    local -a $fv $dv ${fv}h ${dv}h
    star=; repeat $((i-1)) star+='*/'
    (( dofiles )) && set -A $fv ${~star}*(-.omDN)
    (( dodirs ))  && set -A $dv ${~star}*(-/DN)
    if (( plen )) {
      (( dofiles )) && set -A $fv ${(f)"$(_cd_deep_filter $PREFIX ${(P)fv})"}
      (( dodirs ))  && set -A $dv ${(f)"$(_cd_deep_filter $PREFIX ${(P)dv})"}
    }
    zstyle -s ":completion:${curcontext}" level-$i-max cap || cap=6
    (( i == 1 )) && { zstyle -s ":completion:${curcontext}" level-1-max cap || cap=0 }
    (( i == 2 )) && { zstyle -s ":completion:${curcontext}" level-2-max cap || cap=12 }
    _both_deep_order $fv $dv $cap
    vhdr='*'; repeat $((i-1)) vhdr+='/*'
    hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$vhdr
    if (( i == 1 )) { vtag=pwd; htag=pwd-h } else { vtag=pwd-$((i-1)); htag=pwd-$((i-1))-h }
    _both_deep_emit $fv $dv $vtag $htag "$vhdr" "$hhdr"
  done

  #[what] relative-up groups: siblings (../*), siblings' children (../*/*), grandparent children (../../*), parent great-grandchildren (../*/*/*); each drops the entry duplicating PWD / its children / the parent
  local up_p=${PWD:h:t} up_g=${PWD:h:h:t}
  local -a upglob=( '../*' '../*/*' '../../*' '../*/*/*' )
  local -a updrop=( "../${PWD:t}" "../${PWD:t}/*" "../../${PWD:h:t}" "../${PWD:t}/*/*" )
  local -a uphdr=( ".. ${up_p}/*" ".. ${up_p}/*/*" "../.. ${up_g}/*" ".. ${up_p}/*/*/*" )
  for i in {1..$uplevels}; do
    fv=_deep_uf$i; dv=_deep_ud$i
    local -a $fv $dv ${fv}h ${dv}h
    local fpat="${upglob[i]}${_deep_qual_files}" dpat="${upglob[i]}${_deep_qual_dirs}"
    (( dofiles )) && { set -A $fv ${~fpat}; set -A $fv ${(P)fv:#${~updrop[i]}} }
    (( dodirs ))  && { set -A $dv ${~dpat}; set -A $dv ${(P)dv:#${~updrop[i]}} }
    if (( plen )) {
      (( dofiles )) && set -A $fv ${(f)"$(_cd_deep_filter $PREFIX ${(P)fv})"}
      (( dodirs ))  && set -A $dv ${(f)"$(_cd_deep_filter $PREFIX ${(P)dv})"}
    }
    zstyle -s ":completion:${curcontext}" up-$i-max cap || cap=6
    _both_deep_order $fv $dv $cap
    hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$uphdr[i]
    _both_deep_emit $fv $dv up-$i up-$i-h "$uphdr[i]" "$hhdr"
  done

  #[what] base dir-stack group (bare $dirstack, dirs-kind only): the stacked dir itself is a valid cd target but not a file arg, so gated on base-stack
  if [[ $basestack == true ]] {
    local -a stack=( $dirstack )
    (( plen )) && stack=( ${(f)"$(_cd_deep_filter $PREFIX $stack)"} )
    stack=( ${(D)stack} )
    local -a dstack=( ${stack/%//} )
    local expl
    (( $#stack )) && _wanted directory-stack expl 'Stack *' compadd -Q -U -S / -V $stacktag -d dstack -a stack
  }

  #[what] children/grandchildren of the already-pattern-matched stacked dirs, re-filtered by the typed pattern
  local d
  local -a allstack=( $dirstack )
  local -a shdr=( 'Stack */*' 'Stack */*/*' )
  for i in {1..2}; do
    fv=_deep_sf$i; dv=_deep_sd$i
    local -a $fv $dv ${fv}h ${dv}h
    local sstar=; repeat $((i-1)) sstar+='*/'
    if (( plen )) {
      for d in $allstack; do
        (( dofiles )) && set -A $fv ${(P)fv} ${d%/}/${~sstar}*(-.omDN)
        (( dodirs ))  && set -A $dv ${(P)dv} ${d%/}/${~sstar}*(-/DN)
      done
      (( dofiles )) && set -A $fv ${(f)"$(_cd_deep_filter $PREFIX ${(P)fv})"}
      (( dodirs ))  && set -A $dv ${(f)"$(_cd_deep_filter $PREFIX ${(P)dv})"}
    }
    zstyle -s ":completion:${curcontext}" stack-$i-max cap || cap=6
    _both_deep_order $fv $dv $cap
    local -a tmpa; local fvh=${fv}h dvh=${dv}h
    tmpa=( ${(P)fv} );  set -A $fv "${(D)tmpa[@]}"
    tmpa=( ${(P)fvh} ); set -A $fvh "${(D)tmpa[@]}"
    tmpa=( ${(P)dv} );  set -A $dv "${(D)tmpa[@]}"
    tmpa=( ${(P)dvh} ); set -A $dvh "${(D)tmpa[@]}"
    hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$shdr[i]
    _both_deep_emit $fv $dv directory-stack-$i directory-stack-$i-h "$shdr[i]" "$hhdr" $stacktag-$i $stacktag-$i-h
  done

  (( plen && ${+compstate} && compstate[nmatches] )) && compstate[insert]=menu
}
##[<] 🤖🤖🤖

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

##[>] 🤖🤖 thin wrappers: names kept so compdef in .zshrc and PS1's _cd_deep_shortpwd need no change
_cd_deep()   { _deep dirs }
_file_deep() { _deep files }
_both_deep() { _deep both }
##[<] 🤖🤖

##[>] 🤖🤖🤖 shared _deep knobs across cd + file args + both args; per-command lines override by specificity
local _dc_all=':completion:*:*:(cd|vim|vi|nano|cat|less|bat|code|ls|stat):*'
local _dc_deprio=':completion:*:*:(cd|code|ls|stat):*'
local _dc_dstack=':completion:*:*:(cd|vim|vi|nano|cat|less|bat):*'
local _dc_files=':completion:*:*:(vim|vi|nano|cat|less|bat|code|ls|stat):*'
local _dc_cd=':completion:*:cd:*'

zstyle $_dc_all low-precedence '.git' 'node_modules' '.cache'
zstyle $_dc_all level-1-max 0
zstyle $_dc_all level-2-max 12
local _dc_knob
for _dc_knob ( level-3-max level-4-max stack-1-max stack-2-max up-1-max up-2-max up-3-max up-4-max )
  zstyle $_dc_all $_dc_knob 6

zstyle $_dc_deprio deprioritize-name 'test'
zstyle $_dc_dstack stack-tag dstack
zstyle $_dc_files group-order \
  pwd pwd-h pwd-1 pwd-1-h pwd-2 pwd-2-h pwd-3 pwd-3-h \
  up-1 up-1-h up-2 up-2-h up-3 up-3-h up-4 up-4-h \
  directory-stack-1 directory-stack-1-h directory-stack-2 directory-stack-2-h

zstyle $_dc_cd levels 3
zstyle $_dc_cd up-levels 3
zstyle $_dc_cd base-stack true
zstyle $_dc_cd group-order \
  pwd pwd-h pwd-1 pwd-1-h pwd-2 pwd-2-h \
  up-1 up-1-h up-2 up-2-h up-3 up-3-h \
  directory-stack directory-stack-1 directory-stack-1-h directory-stack-2 directory-stack-2-h

unset _dc_all _dc_deprio _dc_dstack _dc_files _dc_cd _dc_knob
##[<] 🤖🤖🤖
