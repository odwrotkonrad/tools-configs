## Loading Configs

```sh
#[≟] first load (script not yet on PATH)
zsh root-ln/usr/local/scripts/shell/s-rt-load-configs

#[≟] subsequent loads
s-rt-load-configs
```

### Make targets

Host-scoped targets wrap the loading scripts:

```sh
#[≟] install configuration files as links in the system root, creating directories when necessary (same as s-rt-load-configs script)
make run-host-upsert-configs

#[≟] prune broken symlinks if there are any
make run-host-delete-broken-links

#[≟] restart launchd agents & daemons
make run-host-restart-services
```
