## `./Makefile`

### Onto Host:

- `run-host-upsert-configs` — link/copy configs
- `run-host-delete-broken-links` — remove dangling symlinks
- `run-host-mk-dirs` — create  prerequisite dirs
- `run-host-render-templates` — render `*.host.auto.tmpl` to system
- `run-host-install-all` - install tools
- `run-host-restart-services` — reload running service launchagents.
- `run-host-setup` — `run-host-mk-dirs` `run-host-upsert-configs` `run-host-install-all`.

### Onto Repo:

- `run-repo-tests` — pytest
- `run-repo-typecheck` — mypy
- `run-repo-upsert-git-hooks` — lefthook
- `run-repo-render-templates` — render `*.repo.auto.tmpl` in place (incl. `README.md`)
- `run-repo-gen-files` — `docs/data/dirs.gen.md`.
- `run-repo-once` — `.env` `run-repo-upsert-git-hooks`.

#### Files:

- `.env`
- `docs/data/dirs.gen.md` — repo dirs structure
- `README.md` — render `README.md.repo.auto.tmpl` via `run-repo-render-templates`.

## Sync, Convenience, Dev:

- `run-sync-quick` — `run-host-upsert-configs` `run-host-delete-broken-links` `run-repo-upsert-git-hooks`.
- `run-sync-full` — `run-sync-quick` `run-host-render-templates`.
