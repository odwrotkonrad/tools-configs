# Configs

My configuration files

## Configured Tools

- asdf - https://asdf-vm.com/
- claude - https://code.claude.com/
- defaults - macos defaults cmd (defaults – access the macOS user defaults system)
- direnv - https://direnv.net/
- editorconfig - https://editorconfig.org/
- git - https://git-scm.com/
- kitty - https://sw.kovidgoyal.net/kitty/
- man - display online manual documentation pages
- prettier - https://prettier.io/
- ruff - https://docs.astral.sh/ruff/
- ssh - https://man7.org/linux/man-pages/man1/ssh.1.html
- tmux - https://github.com/tmux/tmux/wiki
- vim - https://www.vim.org/
- vscode - https://code.visualstudio.com/
- zsh - https://zsh.sourceforge.io/

## Installing Configs

```sh
# first installation
cd root
find * -type d -exec mkdir -p /{} \;            # create dirs
find * -type f -exec  ln -fvws $PWD/{} /{} \;   # link files

# subsequent installations
fn_load_configs
```

## Documentation

- [Contributing](docs/contributing.md)
- [Comments Convention](docs/comments.md)
