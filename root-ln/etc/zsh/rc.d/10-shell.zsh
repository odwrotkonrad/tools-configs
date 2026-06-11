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
  localoptions
  localtraps
  noappendhistory
  nobeep
  noclobber
  noflowcontrol
  nohistbeep
  nohup
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
  #[≟] disabled by default
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
  localpatterns
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
  nullglob
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

#[…] parameters
typeset -A zsh_params=(
  histchars       '!^#'                         #[≟] histexpand-char quicksubst-char comment-char (defaults)
  HISTFILE    "${XDG_STATE_HOME}/zsh/history"
  HISTSIZE    15_000
  PS1         '%1~ %# '                         #[≟] cwd-basename prompt-sigil (%#: # root, %% user)
  PS2         '> '                              #[≟] continuation-line prompt
  PS4         '+ '                              #[≟] prompt when debugging prompt with XTRACE is set
  SAVEHIST    10_000
)
for k v in "${(@kv)zsh_params}"; typeset "$k=$v"
#[⫶] parameters
