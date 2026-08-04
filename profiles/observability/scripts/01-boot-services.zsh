#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh

fpath=(${0:a:h}/../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-is-virt fn-is-os fn-boot-service
fn-is-virt && return 0
fn-is-os mac || return 0
setopt errexit pipefail

for svc ( grafana loki dir-size-exporter port-exporter ) fn-boot-service $svc
##[<] 🤖🤖
