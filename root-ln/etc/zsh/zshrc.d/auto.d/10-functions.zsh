#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

function fn_otel_resource_cwd {
  export OTEL_RESOURCE_ATTRIBUTES="cwd=${PWD},project=${PWD:t}"
}
add-zsh-hook chpwd fn_otel_resource_cwd
fn_otel_resource_cwd

function fn_auth_glab {
  local cfg=${XDG_CONFIG_HOME:-$HOME/.config}/glab-cli/config.yml
  [[ -s $cfg ]] || glab --help >/dev/null 2>&1  #[why] any glab run, even --help, generates config.yml
  yq -e '(.hosts."gitlab.com".token // "") != ""' $cfg >/dev/null 2>&1 && return 0
  local token=$(op read "op://ProgrammaticAccess/gitlab_pat/password")
  [[ -n $token ]] && yq -i ".hosts.\"gitlab.com\".token = \"$token\"" $cfg
}

function fn_preexec_dispatch {
  case ${1} in
    glab*) fn_auth_glab ;;
  esac
  return 0
}
add-zsh-hook preexec fn_preexec_dispatch

##[>] 🤖🤖 do not add cmds starting (after 0+ whitespace) with a histchars char to history
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
