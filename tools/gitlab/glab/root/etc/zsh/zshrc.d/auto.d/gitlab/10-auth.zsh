#[where] $ man zshcontrib (Manipulating Hook Functions)

autoload -Uz add-zsh-hook

##[>] 🤖🤖
#[why] read the gitlab token from $GITLAB_TOKEN_SECRET_PATH (op:// on host/vm, gcp:// in the sandbox pod, toggled in 10-params-secrets): che's secret resolver handles both schemes, so this function stays context-agnostic
function fn_auth_glab {
  glab auth status >/dev/null 2>&1 && return 0
  local token=$(print -r -- '{{ secret (getenv "GITLAB_TOKEN_SECRET_PATH") }}' | render-tpl -f /dev/stdin 2>/dev/null)
  [[ -n $token ]] && print -r -- $token | glab auth login --hostname gitlab.com --stdin
}

#[why] git-mr-upsert/git-upsert-all run glab detached: re-auth before they launch (a che sync clobbers the copied config.yml, logging glab out)
function fn_preexec_auth_glab {
  case ${1} in
    glab*|git-mr-upsert*|git-upsert-all*) fn_auth_glab ;;
  esac
  return 0
}
add-zsh-hook preexec fn_preexec_auth_glab
##[<] 🤖🤖
