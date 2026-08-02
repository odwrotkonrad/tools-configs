#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

function fn_otel_resource_cwd {
  export OTEL_RESOURCE_ATTRIBUTES="cwd=${PWD},project=${PWD:t}"
}
add-zsh-hook chpwd fn_otel_resource_cwd
fn_otel_resource_cwd

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
