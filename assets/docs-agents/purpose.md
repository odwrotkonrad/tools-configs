# Purpose

## What It Is

Git-tracked dotfiles extended into root OS space: every option explicitly configured, scripts, observability stack. Loaded onto the host from one `root/` tree by che: symlinked by default, `.ontoHost.cp` copied, `*.ontoHost.tpl` rendered onto the host. `*.ontoRepo.tpl` renders repo docs and vm vars onto the repo.

## Why It Exists

Records a system's stateful configuration for reading and future reference, not frequent software updates: explicit configuration, modified settings separated from defaults, annotated choices.

## Goals

- Every configuration option explicit: defaults marked, modifications separated.
- One `root/` tree loads onto any supported host profile (desktop/macos, cli/macos, cli/linux).
- Generated docs stay fresh: tools inventory, Makefile doc, repo tree, agent files, README.

