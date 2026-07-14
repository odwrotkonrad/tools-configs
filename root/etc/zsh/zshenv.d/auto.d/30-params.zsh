typeset -g WORDCHARS=""  #[what] non-alnum chars counted as word; empty = strict word boundaries

##[>] 🤖🤖
#[why] full secret ref the shell reads the gitlab token from, toggled by context: virt (sandbox pod + macos-vm, GCP SA key injected -> ADC) reads gcp://, host reads op://. one env, one predicate (fn-is-virt), so every consumer (fn_auth_glab) stays context-agnostic
if { fn-is-virt } {
  export GITLAB_TOKEN_SECRET_PATH='gcp://main-493613/sandbox-gitlab-group-token'
} else {
  export GITLAB_TOKEN_SECRET_PATH='op://ProgrammaticAccess/gitlab/access_token'
}
##[<] 🤖🤖
