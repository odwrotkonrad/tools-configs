## **Config**uration file**s**

## Purpose

To maintain a stateful configuration of a system and tools.

Optimized for a reader, future reference and not frequent, regular software updates to facilitate config options review:

- Comprehensive, explicit configuration including all possible settings.
- Modified settings differing from defaults are separated from unmodified settings.
- Explicitly include every configuration option, marking which are defaults and which are modified.
- Standarized information annotation specified in @docs/comments.md, for explaining choices and pointing to documentation.

## Tools Inventory Index

Tool -> primary config file.

```yaml
#[…] primary
claude: root-ln/Users/ko/.config/claude/settings.json
defaults: root-ln/etc/defaults.yml
duti: root-ln/etc/custom/os-open-files-with.yml
git: root-ln/Users/ko/.config/git/config
grafana: root-ln/etc/grafana/grafana.ini
jaeger: root-ln/etc/jaeger/config.yml
kitty: root-ln/Users/ko/.config/kitty/kitty.conf
lefthook: root-ln/Users/ko/.config/lefthook/lefthook.yml
otelcol: root-ln/etc/otelcol/config.yml
prometheus: root-ln/etc/prometheus/prometheus.yml
rg: root-ln/etc/rg/rgrc
ssh: root-ln/Users/ko/.ssh/config
vscode: root-ln/Users/ko/Library/Application Support/Code/User/settings.json
zsh: root-ln/etc/zshrc
#[⫶]

#[…] other
asdf: root-ln/Users/ko/.config/asdf/.asdfrc
direnv: root-ln/Users/ko/.config/direnv/direnv.toml
editorconfig: root-ln/Users/ko/.editorconfig
fzf: root-ln/etc/zsh/rc.d/20-tools.zsh
golang: root-ln/etc/zshenv
homebrew: root-ln/etc/zshrc
loki: root-ln/etc/loki/config.yml
man: root-ln/etc/man.conf
nvm: root-ln/Users/ko/.nvmrc
prettier: root-ln/Users/ko/.config/prettier/.prettierrc.yml
pyenv: root-ln/etc/zshenv
ruff: root-ln/Users/ko/.config/ruff/ruff.toml
tmux: root-ln/Users/ko/.config/tmux/tmux.conf
vim: root-ln/Users/ko/.config/vim/vimrc
#[⫶]
```

- [docs/data/tools-inventory-full.yml](docs/data/tools-inventory-full.yml) — Full file lists per tool.

## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](docs/readme/images/grafana-claude-code-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-cc-dashboard.gif) · [more](docs/readme/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](docs/readme/images/grafana-host-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-host-dashboard.gif) · [more](docs/readme/images/grafana-host-dashboard-pt-2.png)
