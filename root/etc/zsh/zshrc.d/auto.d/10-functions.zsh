#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

function fn_otel_resource_cwd {
  export OTEL_RESOURCE_ATTRIBUTES="cwd=${PWD},project=${PWD:t}"
}
add-zsh-hook chpwd fn_otel_resource_cwd
fn_otel_resource_cwd

function fn_auth_glab {
  glab auth status >/dev/null 2>&1 && return 0
  local token=$(op read "op://ProgrammaticAccess/gitlab/access_token")
  [[ -n $token ]] && print -r -- $token | glab auth login --hostname gitlab.com --stdin
}

function fn_auth_codex {
  codex login status >/dev/null 2>&1 && return 0
  local key=$(op read "op://ProgrammaticAccess/codex/api_key")
  [[ -n $key ]] && print -r -- $key | codex login --with-api-key
}

function fn_preexec_dispatch {
  case ${1} in
    glab*)  fn_auth_glab ;;
    codex*) fn_auth_codex ;;
  esac
  return 0
}
add-zsh-hook preexec fn_preexec_dispatch

add-zsh-hook chpwd  fn-env-autoload
add-zsh-hook precmd fn-env-autoload

##[>] 🤖🤖 skip history for cmds starting (after ws) with a histchars char
function zshaddhistory {
  emulate -L zsh
  [[ $1 != [[:space:]]#[${histchars}]* ]]
}
##[<]

function command_not_found_handler {
  if [[ -e $1 && -o interactive && -t 0 ]]; then
    local reply
    read -q "reply?open ${1}? [y/N] " </dev/tty
    print
    if [[ $reply == y ]]; then
      open -- "$1"
      return $?
    fi
  fi
  print -u2 "zsh: command not found: $1"
  return 127
}
