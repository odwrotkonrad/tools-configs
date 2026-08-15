#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

##[>] 🤖🤖
function fn-auth-codex {
  codex login status >/dev/null 2>&1 && return 0
  local key=$(op read "op://ProgrammaticAccess/codex/api_key")
  [[ -n $key ]] && print -r -- $key | codex login --with-api-key
}

function fn-preexec-auth-codex {
  case ${1} in
    codex*) fn-auth-codex ;;
  esac
  return 0
}
add-zsh-hook preexec fn-preexec-auth-codex
##[<] 🤖🤖
