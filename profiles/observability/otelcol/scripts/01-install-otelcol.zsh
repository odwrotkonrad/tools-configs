#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh
setopt errexit pipefail

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-install

fn-install otelcol

autoload -Uz fn-is-os fn-is-virt fn-boot-service
if { ! fn-is-virt && fn-is-os mac } fn-boot-service otelcol
##[<] 🤖🤖
