## **Config**uration file**s**

To maintain a stateful configuration of a system and tools.

Optimized for a reader, future reference and not frequent, regular software updates to facilitate config options review:

- Comprehensive, explicit configuration including all possible settings.
- Modified settings differing from defaults are separated from unmodified settings.
- Explicitly include every configuration option, marking which are defaults and which are modified.
- Standarized information annotation specified in @docs/comments.md, for explaining choices and pointing to documentation.

## Tools Inventory Index

Tool -> primary config file.

```yaml
asdf: root-ln/Users/ko/.config/asdf/.asdfrc
claude: root-ln/Users/ko/.config/claude/settings.json
defaults: root-ln/etc/defaults.yml
direnv: root-ln/Users/ko/.config/direnv/direnv.toml
duti: root-ln/etc/custom/os-open-files-with.yml
editorconfig: root-ln/Users/ko/.editorconfig
fzf: root-ln/etc/zsh/rc.d/20-tools.zsh
git: root-ln/Users/ko/.config/git/config
golang: root-ln/etc/zshenv
grafana: root-ln/etc/grafana/grafana.ini
homebrew: root-ln/etc/zshrc
jaeger: root-ln/etc/jaeger/config.yml
kitty: root-ln/Users/ko/.config/kitty/kitty.conf
lefthook: root-ln/Users/ko/.config/lefthook/lefthook.yml
loki: root-ln/etc/loki/config.yml
man: root-ln/etc/man.conf
nvm: root-ln/Users/ko/.nvmrc
otelcol: root-ln/etc/otelcol/config.yml
prettier: root-ln/Users/ko/.config/prettier/.prettierrc.yml
prometheus: root-ln/etc/prometheus/prometheus.yml
pyenv: root-ln/etc/zshenv
rg: root-ln/etc/rg/rgrc
ruff: root-ln/Users/ko/.config/ruff/ruff.toml
ssh: root-ln/Users/ko/.ssh/config
tmux: root-ln/Users/ko/.config/tmux/tmux.conf
vim: root-ln/Users/ko/.config/vim/vimrc
vscode: root-ln/Users/ko/Library/Application Support/Code/User/settings.json
zsh: root-ln/etc/zshrc
```

- [docs/tools-inventory-full.yml](docs/tools-inventory-full.yml) — Full file lists per tool.
