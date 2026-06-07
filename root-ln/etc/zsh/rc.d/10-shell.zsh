#[⌖] $ man zshoptions

#[…] enabled options
typeset -a opts_enabled=(
  autopushd
  cdsilent
  combiningchars
  cshnullglob
  extendedglob
  extendedhistory
  histignorespace
  histlexwords
  histverify
  incappendhistorytime
  interactivecomments
  localoptions
  localtraps
  noappendhistory
  nobeep
  noclobber
  nohistbeep
  nohup
  promptsubst
  pushdsilent

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
  braceccl
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
  ignoreeof
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
  noflowcontrol
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
  rcexpandparam
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
  HISTFILE    "${XDG_STATE_HOME}/zsh/history"
  HISTSIZE    15_000
  PS1         '%1~ %# '                         #[≟] cwd-basename prompt-sigil (%#: # root, %% user)
  PS2         '> '                              #[≟] prompt when shell waits for input
  PS4         '+ '                              #[≟] prompt when debugging prompt with XTRACE is set
  SAVEHIST    10_000
)
for k v in "${(@kv)zsh_params}"; typeset "$k=$v"
#[⫶] parameters
