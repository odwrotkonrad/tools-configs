## Loading Configs

```sh
#[what] first load (script not yet on PATH)
zsh root-ln/usr/local/scripts/shell/s-rt-upsert-configs

#[what] subsequent loads
s-rt-upsert-configs
```

### Make targets

Host-scoped targets wrap the loading scripts:

```sh
#[what] install configuration files as links in the system root, creating directories when necessary (same as s-rt-upsert-configs script)
make run-host-upsert-configs

#[what] prune broken symlinks if there are any
make run-host-delete-broken-links

#[what] restart launchd agents & daemons
make run-host-restart-services
```
