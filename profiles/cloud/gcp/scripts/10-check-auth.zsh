#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-exit-with

[[ -n ${GCP_SA_KEY:-} ]] && return 0
[[ -n ${GOOGLE_APPLICATION_CREDENTIALS:-} ]] && return 0
[[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/gcloud/application_default_credentials.json ]] && return 0

fn-exit-with 1 "gcp credential must be injected at pod creation (GCP_SA_KEY or GOOGLE_APPLICATION_CREDENTIALS)"
##[<] 🤖🤖
