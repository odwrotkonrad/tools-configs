#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-log-msg fn-exit-with

if { op whoami >/dev/null 2>&1 } {
  fn-log-msg "op: already authenticated"
  return 0
}

token=$(security find-generic-password -s op-service-account-token -w 2>/dev/null || true)

if [[ -z $token ]] {
  read -s "token?op service account token: "
  print
  [[ -n $token ]] || fn-exit-with 1 "op: no token given"
  OP_SERVICE_ACCOUNT_TOKEN=$token op whoami >/dev/null || fn-exit-with 1 "op: token rejected"
  security add-generic-password -a $USER -s op-service-account-token -w $token
  fn-log-msg "op: token stored in login keychain"
} else {
  OP_SERVICE_ACCOUNT_TOKEN=$token op whoami >/dev/null || fn-exit-with 1 "op: keychain token rejected"
  fn-log-msg "op: keychain token valid"
}
##[<] 🤖🤖
