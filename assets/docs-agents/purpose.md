# Purpose

## What It Is

Git-tracked dotfiles extended into root OS space: every option explicitly configured, scripts, observability stack. Loaded onto the host from one `root/` tree by che: symlinked by default, `.host.cp` copied, `*.host.tpl` rendered onto the host. `*.repo.tpl` renders repo docs and vm vars onto the repo.

## Why It Exists

Maintains stateful configuration of a system and its tools, optimized for a reader and future reference, not frequent software updates: comprehensive explicit configuration, modified settings separated from defaults, annotated choices.

## Goals

- Every configuration option explicit: defaults marked, modifications separated.
- One `root/` tree loads onto any supported host profile (desktop/macos, cli/macos, cli/linux).
- Generated docs stay fresh: tools inventory, Makefile doc, repo tree, agent files, README.

## How To Use

`make run-sync` loads configs, dirs, hooks, and renders all templates (repo + host). `make run-sync-full` adds the profile's install scripts. `make render-templates` regenerates repo docs. Virt targets build and test macOS and linux images.

## Future Direction

- `docs-human` variants of the generated docs.
- Config coverage grows with the toolchain.
