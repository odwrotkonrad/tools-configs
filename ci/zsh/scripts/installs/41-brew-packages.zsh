#!/bin/zsh
#>[what]
#   brew bundle /etc/homebrew/Brewfile, one stage per call:
#   tap -> formulae -> go -> npm -> cask -> vscode (taps first; cask/vscode last for code cli).
#   Brewfile gates on HOMEBREW_STAGE + HOMEBREW_IS_VIRT.
#   #[why] brew wipes env (bin/brew: env -i), keeps allowlist + HOMEBREW_*. gate
#   vars must be HOMEBREW_-prefixed.
#/[what]

emulate -LR zsh
setopt errexit pipefail

##[>] 🤖🤖
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
typeset -a stages=( tap formulae go npm )
fn-is-os mac && stages+=( cask vscode ) #[why] casks are macos-only 🤖
for stage ( $stages ) bundle_stage $stage
##[<] 🤖🤖
