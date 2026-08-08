#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-boot-service
for svc ( dir-size-exporter port-exporter ) fn-boot-service $svc
##[<] 🤖🤖
