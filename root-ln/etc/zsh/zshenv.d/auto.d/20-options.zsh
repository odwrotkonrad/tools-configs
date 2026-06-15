#[⌖] $ man zshoptions

#[…] enabled options
typeset -a opts_enabled=(
  autopushd
  braceccl #[≟] print 1{abw-z}2 -> 1a2 1b2 1w2 1x2 1y2 1z2
  cdsilent
  combiningchars
  cshnullglob
  extendedglob
  extendedhistory
  histignorespace
  histlexwords
  histverify
  ignoreeof
  incappendhistorytime
  interactivecomments
  noappendhistory
  nobeep
  noclobber
  noflowcontrol
  nohistbeep
  nohup
  nullglob #[≟] non-matching globs expand to nothing instead of erroring
  promptsubst
  pushdsilent
  rcexpandparam #[≟] array=(one two); print X${array}Y -> XoneY XtwoY

  #[≟] auto enabled by shell
  # interactive
  # login
  # monitor
  # shinstdin
  # zle
)
for opt in ${opts_enabled}; setopt ${opt}
#[⫶] enabled options

#[…] disabled options
typeset -a opts_disabled=(
  aliasfuncdef
  allexport
  alwaystoend
  appendcreate
  autocd
  autocontinue
  autonamedirs
  autoresume
  bashautolist
  bashrematch
  bsdecho
  casepaths
  cbases
  cdablevars
  chasedots
  chaselinks
  clobberempty
  completealiases
  completeinword
  continueonerror
  correct
  correctall
  cprecedences
  cshjunkiehistory
  cshjunkieloops
  cshjunkiequotes
  cshnullcmd
  dvorak
  emacs
  errexit
  errreturn
  forcefloat
  globassign
  globcomplete
  globdots
  globstarshort
  globsubst
  hashexecutablesonly
  histallowclobber
  histexpiredupsfirst
  histfcntllock
  histfindnodups
  histignorealldups
  histignoredups
  histnofunctions
  histnostore
  histreduceblanks
  histsavenodups
  histsubstpattern
  ignorebraces
  ignoreclosebraces
  incappendhistory
  ksharrays
  kshautoload
  kshglob
  kshtypeset
  kshzerosubscript
  kshoptionprint
  listpacked
  listrowsfirst
  localloops
  localoptions #[∵] off here, re-enabled at end of .zshrc so a user-invoked function's setopt won't leak to the shell; on during config run so loader functions can scope their own options
  localpatterns
  localtraps   #[∵] same as localoptions
  longlistjobs
  magicequalsubst
  mailwarning
  markdirs
  menucomplete
  noaliases
  noalwayslastprompt
  noautolist
  noautomenu
  noautoparamkeys
  noautoparamslash
  noautoremoveslash
  nobadpattern
  nobanghist
  nobareglobqual
  nobgnice
  nocaseglob
  nocasematch
  nocheckjobs
  nocheckrunningjobs
  nodebugbeforecmd
  noequals
  noevallineno
  noexec
  nofunctionargzero
  noglob
  noglobalexport
  noglobalrcs
  nohashcmds
  nohashdirs
  nohashlistall
  nohistsavebycopy
  nolistambiguous
  nolistbeep
  nolisttypes
  nomultibyte
  nomultifuncdef
  nomultios
  nonomatch
  nonotify
  nopromptcr
  nopromptpercent
  nopromptsp
  norcs
  noshortloops
  nounset
  numericglobsort
  octalzeroes
  overstrike
  pathdirs
  pathscript
  pipefail
  posixaliases
  posixargzero
  posixbuiltins
  posixcd
  posixidentifiers
  posixjobs
  posixstrings
  posixtraps
  printeightbit
  printexitvalue
  privileged
  promptbang
  pushdignoredups
  pushdminus
  pushdtohome
  rcquotes
  recexact
  rematchpcre
  restricted
  rmstarsilent
  rmstarwait
  sharehistory
  shfileexpansion
  shglob
  shnullcmd
  shoptionletters
  shortrepeat
  shwordsplit
  singlecommand
  singlelinezle
  sourcetrace
  sunkeyboardhack
  transientrprompt
  trapsasync
  typesetsilent
  typesettounset
  verbose
  vi
  warncreateglobal
  warnnestedvar
  xtrace
)
for opt in ${opts_disabled}; unsetopt ${opt}
#[⫶] disabled options
