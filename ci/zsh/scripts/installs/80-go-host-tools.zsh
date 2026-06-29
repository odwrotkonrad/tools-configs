#!/bin/zsh
#[what] go install host-runtime tools into $GOPATH/bin (get-os/get-term-open-files-with)

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
goroot=/usr/local/go
projects_dir="${HOME}/projects/go"

function go_install_dir { PATH="${goroot}/bin:${PATH}" go -C "$1" install ./... }

for tool ( get-os-open-files-with get-term-open-files-with ) {
  go_install_dir "${projects_dir}/${tool}"
}
##[<] 🤖🤖
