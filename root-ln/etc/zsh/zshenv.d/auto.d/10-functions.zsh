#[≟] short helper functions, defined inline and loaded eagerly for every shell

#[…] predicates
is-os() {
  typeset os_name=$(uname -s)
  case ${1} {
    (mac)   [[ $os_name == Darwin ]] ;;
    (linux) [[ $os_name == Linux ]] ;;
    (*) return 2 ;;
  }
}
is-arch() {
  hw_platform=$(uname -m)
  case ${1} {
    (arm) [[ $hw_platform == (arm64|aarch64) ]] ;;
    (x86) [[ $hw_platform == (x86_64|amd64) ]] ;;
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
