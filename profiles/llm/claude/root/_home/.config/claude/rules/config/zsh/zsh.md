---
paths:
  - "**/zsh/**"
  - "**/zshrc"
  - "**/zshenv"
  - "**/zlogin"
  - "**/zprofile"
  - "**/zlogout"
---

## ZSH Config

### Files

```yml
- zsh:
    files:
      profiles/shell/zsh/base/:                                      # bare-minimal profile: zsh + rg only
        che.yml:                                            # zsh/base, zsh/base-macos, zsh/base-linux profiles
        root/_home/.config/zsh/:
          .zshenv:
          .zprofile:
          .zshrc:
          .zlogin:
          .zlogout:
          zshenv.d/functions/:                              # autoloaded
          zshrc.d/:                                         # loaded by .zshrc (interactive)
            auto.d/00-base/:                                # per-profile subdir, sourced recursively
              10-params.zsh:
              20-dirs.zsh:
            completions/:
            functions/:
        root/etc/zsh/:
          zshenv.d/:                                        # loaded by /etc/zshenv (all shells)
            fn-loaders.zsh:                                 # autoload helpers
            auto.d/00-base/:                                # per-profile subdir, sourced recursively in path order
              10-options.zsh:
              20-params.zsh:
            functions/:                                     # autoloaded
              fn-exit-with:
              fn-print-with:
              fn-log-msg:
              fn-is-os:                                     # predicate: mac|linux
              fn-is-arch:                                   # predicate: arm|x86
              fn-is-virt:
              fn-is-terminal:                               # predicate: kitty|vscode
              fn-boot-service:
              fn-comp-file-write:
          zshrc.d/:                                         # loaded by /etc/zshrc (interactive)
            static-history.d/:                              # concatenated into each interactive shell, name order
              00-base:
            auto.d/00-base/:
              10-functions-zle.zsh:
              20-params.zsh:
              30-aliases.zsh:
              40-completions.zsh:
              50-keybindings.zsh:
            completions/:
            functions/:
              fn-load-static-history:
              fn-env-autoload:
              fn-open-or-exec:
        root-linux/etc/zsh/:                                # real loader files (linux links them to /etc/zsh)
          zshenv:
          zprofile:
          zshrc:
          zlogin:
          zlogout:
        root-macos/etc/:                                    # loader symlinks -> ../../root-linux/etc/zsh/<name>
          zsh/zshenv.d/functions/rm:                        # trash-backed rm (macos-only)
      profiles/shell/zsh/extras/:                                    # tool-coupled zsh config
        che.yml:                                            # zsh/extras profile
        root/_home/.config/zsh/:
          zshenv.d/auto.d/extras/:
            10-params.zsh.ontoHost.tpl:                     # rendered per host (op secret)
            20-tools-env.zsh:                               # tool env + PATH inserts
          zshrc.d/auto.d/extras/:
            10-dirs.zsh.ontoHost.tpl:
            20-tools.zsh:                                   # nvm
        root/etc/zsh/:
          zshenv.d/:
            auto.d/extras/:
              20-tools-env.zsh:
            functions/:
              fn-load-os-open-files-with:
          zshrc.d/:
            static-history.d/:
              50-tools:
            auto.d/extras/:
              10-functions.zsh:
              20-tools-aliases.zsh:
              30-tools.zsh:                                 # pyenv init
      root/usr/local/scripts/:
        shell/:
          load-defaults-config:
```

### Startup Order

`${ZDOTDIR}` = `~/.config/zsh`.

| # | File                          | Shells                  |
| - | ----------------------------- | ----------------------- |
| 1 | /etc/zshenv                   | all                     |
| 2 | ${ZDOTDIR}/.zshenv            | all                     |
| 3 | /etc/zprofile                 | login                   |
| 4 | ${ZDOTDIR}/.zprofile          | login                   |
| 5 | /etc/zshrc                    | interactive             |
| 6 | ${ZDOTDIR}/.zshrc             | interactive             |
| 7 | /etc/zlogin                   | login                   |
| 8 | ${ZDOTDIR}/.zlogin            | login                   |
| - | ${ZDOTDIR}/.zlogout           | login shell exit (1st)  |
| - | /etc/zlogout                  | login shell exit (2nd)  |

Each phase has `<phase>.d/` with `functions/` (autoloaded onto `fpath`) and `auto.d/` (sourced recursively in path name order, each profile owning a subdir, e.g. `auto.d/00-base/`, `auto.d/extras/`). `/etc/zshenv` loads `zshenv.d/` (all shells), `/etc/zshrc` loads `zshrc.d/` (interactive), same split in user space. Put always-available helpers in `zshenv.d/`, interactive-only in `zshrc.d/`.

### Documentation

`$ man`:

- `zshzle`: line editor, keymaps, widgets, bindkey, highlighting
- `zshall`: all-in-one, concatenation, searchable, every section, other zsh pages
- `zshparam`: parameters, arrays, positional, scalars, shell variables
- `zshoptions`: setopt, completion, globbing, history, emulation
- `zshbuiltins`: builtin commands, autoload, setopt, zstyle, bindkey
- `zsh`: overview, invocation, startup files, compatibility, manpage index
- `zshmisc`: grammar, redirection, functions, traps, prompt escapes, conditionals, job control

and these:
- `zshroadmap`: overview, startup, interactive use, pattern matching
- `zshmodules`: zmodload, zsh/complete, zsh/pcre, zsh/zutil, zsh/datetime
- `zshexpn`: expansion, parameter, history, globbing, brace
- `zshcontrib`: prompt themes, vcs_info, zle functions, zcalc, zmv
- `zshcompwid`: completion widgets, compadd, special params, matching control, condition codes
- `zshcompsys`: compinit, compdef, zstyle, completers, autoload
- `stty`: terminal settings, control/input/output/local modes, control chars

Links:

- [XDG base dirs](https://specifications.freedesktop.org/basedir-spec/latest/)
