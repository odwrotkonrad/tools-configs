##[>] 🤖🤖
#[why] sandbox pods receive the restricted SA key as $GCP_SA_KEY (run-session su -w whitelist); materialize it as an ADC file so che's gcp:// secret source authenticates, then drop it from the env
if (( ${+GCP_SA_KEY} )) && [[ -n $GCP_SA_KEY ]] {
  typeset -g GOOGLE_APPLICATION_CREDENTIALS=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/gcp-sa-key.json
  print -r -- $GCP_SA_KEY >| $GOOGLE_APPLICATION_CREDENTIALS
  chmod 0600 $GOOGLE_APPLICATION_CREDENTIALS
  export GOOGLE_APPLICATION_CREDENTIALS
  unset GCP_SA_KEY
}
##[<] 🤖🤖
