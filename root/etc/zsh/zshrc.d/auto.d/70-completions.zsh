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

##[>] 🤖🤖
zstyle ':completion:*' squeeze-slashes true
##[<] 🤖🤖

zstyle ':completion:*' use-cache off
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

##[>] 🤖🤖
zstyle ':completion:*:*:touch:argument-1:*' format ''
##[<] 🤖🤖

##[>] 🤖🤖🤖 one engine drives cd/vim/code deep-path completion; tag-scoped zstyles (file-types kinds+order, groups list, max-hints + deprioritize-hints per group) are its only axes
#[what] glob qualifier per kind: dirs count-desc, files mtime-newest-first; both globs each stream in parallel
_deep_qual_files='(-.omDN)'
_deep_qual_dirs='(-/DN)'

#[what] a path segment matches a deprioritize-hints entry: case-insensitive substring, leading '^' pins segment start, trailing '$' pins segment end
_deep_deprio_hit() {
  local p=$1 seg e body lead trail
  for seg in ${(s:/:)p}; do
    for e in $deprio; do
      body=$e lead='*' trail='*'
      [[ $body == '^'* ]] && { body=${body#^}; lead= }
      [[ $body == *'$' ]] && { body=${body%'$'}; trail= }
      if [[ ${(L)seg} == ${~lead}"${(L)body}"${~trail} ]] return 0
    done
  done
  return 1
}

#[what] partition a dir list into two count-desc streams: visible (normal) then a lone '--' delimiter line then hidden dirs then deprioritized, each by item-count desc; '--' after print's own '--' so an empty visible stream keeps the delimiter
_cd_deep_order() {
  local -a dirs=( "$@" ) items
  local -a normal hidden demoted
  local p n
  for p in $dirs; do
    local -a items=( $p/*(ND) )
    n=$#items
    if { _deep_deprio_hit $p } { demoted+=( "$n $p" ); continue }
    if [[ $p == (*/|).[^/]##(|/*) ]] { hidden+=( "$n $p" ); continue }
    normal+=( "$n $p" )
  done
  normal=( ${(On)normal} ); hidden=( ${(On)hidden} ); demoted=( ${(On)demoted} )
  print -l -- ${normal#* } -- ${hidden#* } ${demoted#* }
}

#[what] partition a leaf-file list (already mtime newest-first from the glob) into visible then a lone '--' delimiter then hidden then deprioritized, order preserved
_file_deep_order() {
  local -a files=( "$@" )
  local -a normal hidden demoted
  local p
  for p in $files; do
    if { _deep_deprio_hit $p } { demoted+=( $p ); continue }
    if [[ $p == (*/|).[^/]##(|/*) ]] { hidden+=( $p ); continue }
    normal+=( $p )
  done
  print -l -- $normal -- $hidden $demoted
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
#[what] visible ($1) and hidden ($2) share cap $3: visible first, hidden fills the remainder, none left -> no hidden; $3<0 uncapped ($3==0 never reaches here, it disables the group upstream)
_cd_deep_capshare() {
  local m=$3
  (( m < 0 )) && return
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

#[what] order a level's file glob (mtime) and dir glob (count-desc) each by its native criterion, splice kinds in _deep_ft order into one visible and one hidden tagged stream, capshare the pair together, split back into dir/file visible+hidden preserving order and stripping the kind tag
_deep_files_order() {
  local files_v=$1 dirs_v=$2 cap=$3
  local -a fo do fv fh dv dh
  fo=( ${(f)"$(_file_deep_order ${(P)files_v})"} ); fv=( ${fo[1,${fo[(i)--]}-1]} ); fh=( ${fo[${fo[(i)--]}+1,-1]} )
  do=( ${(f)"$(_cd_deep_order ${(P)dirs_v})"} );    dv=( ${do[1,${do[(i)--]}-1]} ); dh=( ${do[${do[(i)--]}+1,-1]} )

  local -a mvis mhid
  local ft
  for ft in $_deep_ft; do
    case $ft {
      (dirs)  mvis+=( ${dv/#/d:} ); mhid+=( ${dh/#/d:} ) ;;
      (files) mvis+=( ${fv/#/f:} ); mhid+=( ${fh/#/f:} ) ;;
    }
  done
  _cd_deep_capshare mvis mhid $cap

  local e
  local -a odv ofv odh ofh
  for e in $mvis; do [[ $e == d:* ]] && odv+=( ${e#d:} ) || ofv+=( ${e#f:} ); done
  for e in $mhid; do [[ $e == d:* ]] && odh+=( ${e#d:} ) || ofh+=( ${e#f:} ); done
  set -A $dirs_v "${odv[@]}"; set -A ${dirs_v}h "${odh[@]}"
  set -A $files_v "${ofv[@]}"; set -A ${files_v}h "${ofh[@]}"
}

#[what] emit one level per kind in _deep_ft order under the shared visible -V tag, then the same under the hidden -V tag; dirs get trailing-/ display and -S / insert; when a stream mixes kinds the compadds under one -V merge into one visual group
#[what] vtag/htag are the completion tags (_wanted, tag-order); vgrp/hgrp are the -V group names (visual grouping, shown in first-compadd order); default vgrp=vtag hgrp=htag so single-name callers pass four args
_deep_files_emit() {
  local files_v=$1 dirs_v=$2 vtag=$3 htag=$4 vhdr=$5 hhdr=$6 vgrp=${7:-$3} hgrp=${8:-$4}
  local files_vh=${files_v}h dirs_vh=${dirs_v}h
  local -a fv=( ${(P)files_v} ) dv=( ${(P)dirs_v} )
  local -a fh=( ${(P)files_vh} ) dh=( ${(P)dirs_vh} )
  local expl ft
  local -a ddv dfv ddh dfh pddv pdfv pddh pdfh
  ddv=( ${dv/%//} ); dfv=( $fv ); ddh=( ${dh/%//} ); dfh=( $fh )
  _cd_deep_quadcols ddv dfv ddh dfh  pddv pdfv pddh pdfh
  for ft in $_deep_ft; do
    case $ft {
      (dirs)  (( $#dv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vgrp -S / -d pddv -a dv } ;;
      (files) (( $#fv )) && { _wanted $vtag expl "$vhdr" compadd -Q -U -V $vgrp        -d pdfv -a fv } ;;
    }
  done
  for ft in $_deep_ft; do
    case $ft {
      (dirs)  (( $#dh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $hgrp -S / -d pddh -a dh } ;;
      (files) (( $#fh )) && { _wanted $htag expl "$hhdr" compadd -Q -U -V $hgrp        -d pdfh -a fh } ;;
    }
  done
}

##[>] 🤖🤖🤖
#[what] group name -> (scope N M): <scope>[-N][+M]; scopes pwd (anchor N ancestors up), absolute (typed base), stack, named-dirs; bare name = anchor children, +M adds depth
_deep_parse_group() {
  local g=$1
  reply=( )
  case $g {
    (named-dirs) reply=( named-dirs 0 0 ) ;;
    (stack) reply=( stack 0 0 ) ;;
    (stack+<->) reply=( stack 0 ${g#stack+} ) ;;
    (absolute) reply=( absolute 0 0 ) ;;
    (absolute+<->) reply=( absolute 0 ${g#absolute+} ) ;;
    (pwd) reply=( pwd 0 0 ) ;;
    (pwd+<->) reply=( pwd 0 ${g#pwd+} ) ;;
    (pwd-<->) reply=( pwd ${g#pwd-} 0 ) ;;
    (pwd-<->+<->) local rest=${g#pwd-}; reply=( pwd ${rest%%+*} ${rest##*+} ) ;;
    (*) return 1 ;;
  }
}

#[what] deep-path completion engine; the file-types list (:completion:${curcontext}: file-types, values dirs/files) selects which globs run AND its order sets per-group kind emission order; a per-kind-empty array reduces the mixed-kind machinery to a single-kind capshare/emit, so cd/vim/code share one body
#[what] the groups list (:completion:${curcontext}: groups) is the sole source of membership + emission order; max-hints and deprioritize-hints read per group tag (:completion:${curcontext}:<group>); each group emits a -h hidden twin right after it
_deep_files() {
  local -a deprio
  #[what] claim the empty function field of the context so styles can target :completion:_deep_files:* across all wrapped commands
  local curcontext=$curcontext
  [[ $curcontext == :* ]] && curcontext="_deep_files$curcontext"

  local -a _deep_ft
  zstyle -a ":completion:${curcontext}:" file-types _deep_ft || _deep_ft=( dirs files )
  local dofiles=$_deep_ft[(Ie)files] dodirs=$_deep_ft[(Ie)dirs]

  local -a groups
  zstyle -a ":completion:${curcontext}:" groups groups ||
    groups=( pwd pwd+1 pwd+2 pwd+3 absolute absolute+1 absolute+2 absolute+3 pwd-1 pwd-1+1 pwd-1+2 pwd-2 )

  local plen=$#PREFIX
  local cap star vhdr hhdr fv dv expl

  #[what] bare ~ prefix (no slash): named-dirs group only, no other scopes
  local namedonly=0
  [[ $PREFIX == '~'[^/]# ]] && namedonly=1
  local absprefix=0
  [[ $PREFIX == [/~]* ]] && absprefix=1

  #[what] absolute scope (/ or ~ prefix): groups rooted at the typed base, pwd groups skipped
  local apat abase ebase aplen dhdrbase
  if (( absprefix && ! namedonly )) {
    apat=${PREFIX##*/}
    abase=${PREFIX%"$apat"}
    [[ -z $abase ]] && abase=${PREFIX}/ && apat=
    ebase=${~abase}; aplen=$#apat
    dhdrbase=${(D)ebase}
  }

  local g gi=0 scope N M d anc droppat
  local -a reply allstack=( $dirstack )
  for g in $groups; do
    _deep_parse_group $g || continue
    (( gi++ ))
    scope=$reply[1] N=$reply[2] M=$reply[3]

    case $scope {
      (pwd)
        (( namedonly || absprefix )) && continue
        zstyle -s ":completion:${curcontext}:$g" max-hints cap || cap=6
        (( cap == 0 )) && continue
        fv=_deep_f$gi; dv=_deep_d$gi
        local -a $fv $dv ${fv}h ${dv}h
        star=; repeat $N star+='../'
        repeat $M star+='*/'
        (( dofiles )) && set -A $fv ${~star}*(-.omDN)
        (( dodirs ))  && set -A $dv ${~star}*(-/DN)
        #[what] drop the entry chain duplicating PWD's lineage: ('../' x N) + (N-1)-th ancestor name + ('/*' x M)
        if (( N )) {
          anc=$PWD
          repeat $((N-1)) anc=${anc:h}
          droppat=; repeat $N droppat+='../'
          droppat+=${anc:t}; repeat $M droppat+='/*'
          (( dofiles )) && set -A $fv ${(P)fv:#${~droppat}}
          (( dodirs ))  && set -A $dv ${(P)dv:#${~droppat}}
        }
        if (( plen )) {
          (( dofiles )) && set -A $fv ${(f)"$(_cd_deep_filter $PREFIX ${(P)fv})"}
          (( dodirs ))  && set -A $dv ${(f)"$(_cd_deep_filter $PREFIX ${(P)dv})"}
        }
        zstyle -a ":completion:${curcontext}:$g" deprioritize-hints deprio || deprio=( test )
        _deep_files_order $fv $dv $cap
        if (( N )) {
          vhdr=; repeat $N vhdr+='../'
          vhdr="${vhdr%/} ${anc:h:t}/*"
        } else {
          vhdr='*'
        }
        repeat $M vhdr+='/*'
        hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$vhdr
        _deep_files_emit $fv $dv $g $g-h "$vhdr" "$hhdr"
        ;;

      (absolute)
        (( namedonly )) && continue
        (( absprefix )) || continue
        zstyle -s ":completion:${curcontext}:$g" max-hints cap || cap=6
        (( cap == 0 )) && continue
        fv=_deep_af$gi; dv=_deep_ad$gi
        local -a $fv $dv ${fv}h ${dv}h
        star=; repeat $M star+='*/'
        (( dofiles )) && set -A $fv ${ebase}${~star}*(-.omDN)
        (( dodirs ))  && set -A $dv ${ebase}${~star}*(-/DN)
        if (( aplen )) {
          local -a rel
          (( dofiles )) && { rel=( ${(P)fv#"$ebase"} ); set -A $fv ${${(f)"$(_cd_deep_filter $apat $rel)"}/#/$ebase} }
          (( dodirs ))  && { rel=( ${(P)dv#"$ebase"} ); set -A $dv ${${(f)"$(_cd_deep_filter $apat $rel)"}/#/$ebase} }
        }
        zstyle -a ":completion:${curcontext}:$g" deprioritize-hints deprio || deprio=( test )
        _deep_files_order $fv $dv $cap
        local -a tmpa; local fvh=${fv}h dvh=${dv}h
        tmpa=( ${(P)fv} );  set -A $fv "${(D)tmpa[@]}"
        tmpa=( ${(P)fvh} ); set -A $fvh "${(D)tmpa[@]}"
        tmpa=( ${(P)dv} );  set -A $dv "${(D)tmpa[@]}"
        tmpa=( ${(P)dvh} ); set -A $dvh "${(D)tmpa[@]}"
        vhdr=${dhdrbase%/}/'*'; repeat $M vhdr+='/*'
        hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$vhdr
        _deep_files_emit $fv $dv $g $g-h "$vhdr" "$hhdr"
        ;;

      (stack)
        (( namedonly )) && continue
        zstyle -s ":completion:${curcontext}:$g" max-hints cap || cap=6
        (( cap == 0 )) && continue
        #[what] base group: bare $dirstack (a valid cd target but not a file arg, so file cmds omit it from groups)
        if (( M == 0 )) {
          local -a stack=( $dirstack )
          (( plen )) && stack=( ${(f)"$(_cd_deep_filter $PREFIX $stack)"} )
          (( cap > 0 && $#stack > cap )) && stack=( $stack[1,cap] )
          stack=( ${(D)stack} )
          #[what] root stays a single slash: emitted without -S / so it inserts '/', not '//'
          local sp; local -a snorm=( )
          for sp in $stack; do [[ $sp != / ]] && sp=${sp%/}; snorm+=( $sp ); done
          stack=( $snorm )
          local -a sroot=( ${(M)stack:#/} ) srest=( ${stack:#/} )
          local -a dstack=( ${srest/%//} )
          (( $#srest )) && _wanted $g expl 'Stack *' compadd -Q -U -S / -V $g -d dstack -a srest
          (( $#sroot )) && { local -a droot=( / ); _wanted $g expl 'Stack *' compadd -Q -U -V $g -d droot -a sroot }
          continue
        }
        #[what] stack+M: descendants of the stacked dirs, globbed only when a prefix is typed
        (( plen )) || continue
        fv=_deep_sf$gi; dv=_deep_sd$gi
        local -a $fv $dv ${fv}h ${dv}h
        star=; repeat $((M-1)) star+='*/'
        for d in $allstack; do
          (( dofiles )) && set -A $fv ${(P)fv} ${d%/}/${~star}*(-.omDN)
          (( dodirs ))  && set -A $dv ${(P)dv} ${d%/}/${~star}*(-/DN)
        done
        (( dofiles )) && set -A $fv ${(f)"$(_cd_deep_filter $PREFIX ${(P)fv})"}
        (( dodirs ))  && set -A $dv ${(f)"$(_cd_deep_filter $PREFIX ${(P)dv})"}
        zstyle -a ":completion:${curcontext}:$g" deprioritize-hints deprio || deprio=( test )
        _deep_files_order $fv $dv $cap
        local -a tmpa; local fvh=${fv}h dvh=${dv}h
        tmpa=( ${(P)fv} );  set -A $fv "${(D)tmpa[@]}"
        tmpa=( ${(P)fvh} ); set -A $fvh "${(D)tmpa[@]}"
        tmpa=( ${(P)dv} );  set -A $dv "${(D)tmpa[@]}"
        tmpa=( ${(P)dvh} ); set -A $dvh "${(D)tmpa[@]}"
        vhdr='Stack *'; repeat $M vhdr+='/*'
        hhdr=; (( ${(P)#fv} + ${(P)#dv} )) || hhdr=$vhdr
        _deep_files_emit $fv $dv $g $g-h "$vhdr" "$hhdr"
        ;;

      (named-dirs)
        #[what] hash -d + dynamic, dirs kind only, relative or bare-~ prefix
        local ndok=$namedonly
        [[ $PREFIX != [/~]* ]] && ndok=1
        (( dodirs && ndok )) || continue
        zstyle -s ":completion:${curcontext}:$g" max-hints cap || cap=6
        (( cap == 0 )) && continue
        local nname
        local -a nnames=( )
        for nname in ${(ok)nameddirs}; do
          [[ $nameddirs[$nname] == $PWD ]] && continue
          if (( plen )) { _cd_deep_fuzzy $PREFIX "~$nname" || continue }
          nnames+=( "~$nname" )
        done
        (( cap > 0 && $#nnames > cap )) && nnames=( $nnames[1,cap] )
        (( $#nnames )) && {
          local -a dnames=( ${nnames/%//} )
          _wanted $g expl '~*' compadd -Q -U -S / -V $g -d dnames -a nnames
        }
        ;;
    }
  done

  (( plen && ${+compstate} && compstate[nmatches] )) && compstate[insert]=menu
}
##[<] 🤖🤖🤖

#[what] home-aware, tail-2-full path: HOME->~, all but the last two segments shrunk to their first char
_cd_deep_shortpwd() {
  ##[>] 🤖🤖
  local h=$1
  [[ $h == $HOME(|/*) ]] && h="~${h#$HOME}"
  ##[<] 🤖🤖
  local -a segs=( ${(s:/:)h} ) ; local n=$#segs
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

##[>] 🤖🤖🤖 shared _deep_files knobs, scoped on the _deep_files function field so they cover every wrapped command; file-types is kind membership + per-group kind order, the groups list is membership + order, max-hints/deprioritize-hints per group tag, per-command lines override by specificity
local _dc=':completion:_deep_files:*'

zstyle "${_dc}:" file-types files
zstyle "${_dc}:cd:*:" file-types dirs
zstyle "${_dc}:(code|ls|stat):*:" file-types dirs files

zstyle "${_dc}:*" max-hints 6
zstyle "${_dc}:(pwd|absolute)" max-hints -1
zstyle "${_dc}:(pwd|absolute)+1" max-hints 12
zstyle "${_dc}:(stack|named-dirs)" max-hints -1

zstyle "${_dc}:*" deprioritize-hints '.git' 'node_modules' 'test'

zstyle "${_dc}:" groups \
  pwd pwd+1 pwd+2 pwd+3 \
  absolute absolute+1 absolute+2 absolute+3 \
  pwd-1 pwd-1+1 pwd-1+2 \
  pwd-2

zstyle "${_dc}:cd:*:" groups \
  pwd pwd+1 pwd+2 \
  absolute absolute+1 absolute+2 \
  pwd-1 pwd-1+1 \
  pwd-2 \
  stack named-dirs

unset _dc
##[<] 🤖🤖🤖
