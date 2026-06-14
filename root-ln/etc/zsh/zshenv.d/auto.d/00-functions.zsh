#>[≟] short helper functions, defined inline and loaded eagerly for every shell
#   larger or lazy functions get their own autoloaded file under ../functions/
#/[≟]

#[…] 🤖🤖 predicates
is-os() {
  case ${1} {
    (mac)   [[ $(uname -s) == Darwin ]] ;;
    (linux) [[ $(uname -s) == Linux ]] ;;
    (*) return 2 ;;
  }
}
is-arch() {
  case ${1} {
    (arm) [[ $(uname -m) == (arm64|aarch64) ]] ;;
    (x86) [[ $(uname -m) == (x86_64|amd64) ]] ;;
    (*) return 2 ;;
  }
}
is-terminal() {
  case ${1} {
    (kitty)  [[ ${TERM} == xterm-kitty ]] ;;
    (vscode) [[ ${TERM_PROGRAM} == vscode ]] ;;
    (*) return 2 ;;
  }
}
#[⫶] predicates

exit-with() {
  local code=$1 msg=$2

  if (( ${+msg} && code==0 )) print -u2 $msg
  if (( ${+msg} && code!=0 )) print $msg

  exit $code
}

#[…] 🤖🤖 print-with <modifier> <text> — styled wrapper over print
print-with() {
  local modifier=$1 text=$2 bar n

  case ${modifier} {
    (bold)  text="%B${text}%b" ;;
    (title) n=$(( (${COLUMNS:-80} - ${#text} - 2) / 2 )); bar=${(l:n::-:)}; text="${bar} %B${text}%b ${bar}" ;;
    (*) return 2 ;;
  }

  print -P -- ${text}
}
#[⫶] print-with
