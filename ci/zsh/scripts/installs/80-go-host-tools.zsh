#!/bin/zsh
#[what] go install host-only published tools into $GOPATH/bin (get-os/get-term-open-files-with)

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
autoload -Uz fn-log-msg

goroot=/usr/local/go
function go_install { PATH="${goroot}/bin:${PATH}" go install "$1" }

#[what] own published go tools, host-only: bin -> module@version
typeset -A own_tools=(
  get-os-open-files-with    'gitlab.com/konradodwrot/go/cruft/get-os-open-files-with@v0.0.2'
  get-term-open-files-with  'gitlab.com/konradodwrot/go/cruft/get-term-open-files-with@v0.0.2'
)

for bin module ( ${(kv)own_tools} ) {
  if (( $+commands[$bin] )) {
    fn-log-msg -t "$bin" -- already installed
    continue
  }
  fn-log-msg -t "$bin" -- installing
  go_install "$module"
  fn-log-msg -t "$bin" -- installed
}
##[<] 🤖🤖
