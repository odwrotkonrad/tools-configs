## **Config**uration file**s**

## Purpose

To maintain a stateful configuration of a system and tools.

Optimized for a reader, future reference and not frequent, regular software updates to facilitate config options review:

- Comprehensive, explicit configuration including all possible settings.
- Modified settings differing from defaults are separated from unmodified settings.
- Explicitly include every configuration option, marking which are defaults and which are modified.
- Standarized information annotation specified in @docs/readme/commenting-convention.md, for explaining choices and pointing to documentation.

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
#[⫶] primary

#[…] other
asdf: root-ln/Users/ko/.config/asdf/.asdfrc
aws: root-ln/Users/ko/.config/aws/config.auto.tmpl
azure: root-ln/Users/ko/.config/azure/config
direnv: root-ln/Users/ko/.config/direnv/direnv.toml
editorconfig: root-ln/Users/ko/.editorconfig
fzf: root-ln/etc/zsh/rc.d/20-tools.zsh
gcloud: root-ln/Users/ko/.config/gcloud/configurations/config_main.auto.tmpl
golang: root-ln/etc/zshenv
gomplate: root-ln/etc/gomplate/gomplate.yaml
homebrew: root-ln/etc/zshrc
loki: root-ln/etc/loki/config.yml
man: root-ln/etc/man.conf
mypy: root-ln/Users/ko/.config/mypy/config
nvm: root-ln/Users/ko/.nvmrc
ollama: root-ln/Users/ko/.ollama/server.json
prettier: root-ln/Users/ko/.config/prettier/.prettierrc.yml
pyenv: root-ln/etc/zshenv
ruff: root-ln/Users/ko/.config/ruff/ruff.toml
tmux: root-ln/Users/ko/.config/tmux/tmux.conf
vim: root-ln/Users/ko/.config/vim/vimrc
#[⫶] other
```

- [docs/data/tools-inventory-full.yml](docs/data/tools-inventory-full.yml) - Full file lists per tool.

## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](docs/readme/images/grafana-claude-code-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-cc-dashboard.gif) · [more](docs/readme/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](docs/readme/images/grafana-host-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-host-dashboard.gif) · [more](docs/readme/images/grafana-host-dashboard-pt-2.png)

## ☢️ Danger Zone - Loading Configs ☢️

Loading configuration directly modifies the OS, including system, non-user files. If you find anything of interest, prefer copying these pieces into your own config.

[Loading Configs](docs/readme/loading-configuration.md)
