#!/bin/zsh
#>[what]
#   brew bundle /etc/homebrew/Brewfile, one stage per call:
#   formulae -> npm -> cask.
#   Brewfile gates on HOMEBREW_STAGE + HOMEBREW_IS_VIRT.
#   #[why] brew wipes env (bin/brew: env -i), keeps allowlist + HOMEBREW_*. gate
#   vars must be HOMEBREW_-prefixed.
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-log-msg fn-is-virt fn-is-os

export NONINTERACTIVE=1
export HOMEBREW_NO_ASK=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
#[why] gates Brewfile virt? predicate, detected here not threaded from che
fn-is-virt && export HOMEBREW_IS_VIRT=true || export HOMEBREW_IS_VIRT=false

#[why] parallel installs collide on shared-dep locks, cache races. bundle
#   idempotent, retry 3x clears transient failures, then give up.
function bundle_stage {
  local stage=$1 attempt
  fn-log-msg -t brew -- "installing stage: $stage"
  for attempt ( 1 2 3 ) {
    HOMEBREW_STAGE=$stage brew bundle install --jobs auto --no-upgrade --file=$brewfile && return 0
    fn-log-msg -t brew -- "stage $stage failed (attempt $attempt/3), retrying"
  }
  return 1
}

typeset brewfile=/etc/homebrew/Brewfile
typeset -a stages=( formulae npm )
fn-is-os mac && stages+=( cask ) #[why] casks are macos-only 🤖
for stage ( $stages ) bundle_stage $stage

#[why] brew zsh can ride in as a formula dependency and would shadow /usr/bin/zsh with a different compiled-in rc dir (/etc vs debian's /etc/zsh): unlink it, one zsh owns the shell 🤖🤖
if { fn-is-os linux && brew list zsh >/dev/null 2>&1 } brew unlink zsh
##[<] 🤖🤖
