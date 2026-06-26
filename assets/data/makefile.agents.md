## `./Makefile`

### Onto Host:

`run-host-render-templates`
`run-host-delete-broken-links`
`run-host-install-all`
`run-host-mk-dirs`
`run-host-restart-services` reload launchagents
`run-host-upsert-configs` link/copy dotfiles/configs

### Onto Repo:

`run-repo-tests` pytest
`run-repo-typecheck` mypy
`run-repo-upsert-git-hooks` lefthook
`run-repo-render-templates` templates/

## Sync, Convenience, Dev:

`run-sync-quick`: `run-host-upsert-configs -> run-host-delete-broken-links -> run-repo-upsert-git-hooks -> run-repo-render-templates`
`run-sync-full`: `run-sync-quick -> run-host-mk-dirs -> run-host-render-templates`
