#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

##[>] 🤖🤖
#[why] native glab env auth: export $GITLAB_TOKEN from $GITLAB_TOKEN_SECRET_PATH (op:// on host/vm, gcp:// in the sandbox pod, toggled in 10-params-secrets): token lives only in shell env, glab auth login would persist it into ~/.config/glab-cli/config.yml
function fn_auth_glab {
  (( ${+GITLAB_TOKEN} )) && return 0
  local token=$(print -r -- '{{ secret (getenv "GITLAB_TOKEN_SECRET_PATH") }}' | render-tpl -f /dev/stdin 2>/dev/null)
  [[ -n $token ]] && export GITLAB_TOKEN=$token
}

#[why] git-mr-upsert/git-upsert-all run glab detached: they inherit $GITLAB_TOKEN from the invoking shell, so the hook must fire on them too
function fn_preexec_auth_glab {
  case ${1} in
    glab*|git-mr-upsert*|git-upsert-all*) fn_auth_glab ;;
  esac
  return 0
}
add-zsh-hook preexec fn_preexec_auth_glab
##[<] 🤖🤖
