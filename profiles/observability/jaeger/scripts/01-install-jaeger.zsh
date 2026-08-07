#!/bin/zsh
##[>] 🤖🤖

emulate -LR zsh

fpath=(${0:a:h}/../../../shell/zsh/base/root/etc/zsh/zshenv.d/functions $fpath)
autoload -Uz fn-is-virt fn-is-os
fn-is-virt && return 0
fn-is-os mac || return 0

setopt errexit pipefail

autoload -Uz fn-install fn-boot-service

fn-install jaeger
fn-boot-service jaeger
##[<] 🤖🤖
