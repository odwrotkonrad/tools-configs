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
      root/HOME/.config/zsh/:
        .zshenv:
        .zprofile:
        .zshrc:
        .zlogin:
        .zlogout:
        zshenv.d/:                                          # loaded by .zshenv (all shells)
          auto.d/:                                          # sourced in name order
            30-params.zsh.host.tpl:                   # rendered per host
            81-claude.zsh:                                  # man-as-text, clobber; guarded on CLAUDECODE
          functions/:                                       # autoloaded
        zshrc.d/:                                           # loaded by .zshrc (interactive)
          auto.d/:
            30-params.zsh:
            50-dirs.zsh:
            80-tools.zsh:
          completions/:
          functions/:
      root/etc/:
        zshenv:
        zprofile:
        zshrc:
        zlogin:
        zlogout:
        zsh/:
          zshenv.d/:                                        # loaded by /etc/zshenv (all shells)
            fn-loaders.zsh:                                 # autoload helpers
            auto.d/:                                        # sourced in name order
              20-options.zsh:
              30-params.zsh:
            functions/:                                     # autoloaded
              rm:
              fn-exit-with:
              fn-print-with:
              fn-is-os:                                     # predicate: mac|linux
              fn-is-arch:                                    # predicate: arm|x86
              fn-is-terminal:                               # predicate: kitty|vscode
              fn-load-os-open-files-with:
              fn-ssh-generate-keys:
              fn-ssh-test-git-connection:
          zshrc.d/:                                         # loaded by /etc/zshrc (interactive)
            static-history:                                 # items loaded into each interactive shell
            auto.d/:
              00-local.zsh:
              10-functions.zsh:
              11-functions-zle.zsh:
              30-params.zsh:
              40-aliases.zsh:
              80-tools.zsh:
              90-keybindings.zsh:
            completions/:
            functions/:
              fn-load-static-history:
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

Each phase has `<phase>.d/` with `functions/` (autoloaded onto `fpath`) and `auto.d/` (sourced in name order). `/etc/zshenv` loads `zshenv.d/` (all shells); `/etc/zshrc` loads `zshrc.d/` (interactive); same split in user space. Put always-available helpers in `zshenv.d/`, interactive-only in `zshrc.d/`.

### Documentation

`$ man`:

- `zshzle` — line editor, keymaps, widgets, bindkey, highlighting
- `zshall` — all-in-one, concatenation, searchable, every section, other zsh pages
- `zshparam` — parameters, arrays, positional, scalars, shell variables
- `zshoptions` — setopt, completion, globbing, history, emulation
- `zshbuiltins` — builtin commands, autoload, setopt, zstyle, bindkey
- `zsh` — overview, invocation, startup files, compatibility, manpage index
- `zshmisc` — grammar, redirection, functions, traps, prompt escapes, conditionals, job control

and these:
- `zshroadmap` — overview, startup, interactive use, pattern matching
- `zshmodules` — zmodload, zsh/complete, zsh/pcre, zsh/zutil, zsh/datetime
- `zshexpn` — expansion, parameter, history, globbing, brace
- `zshcontrib` — prompt themes, vcs_info, zle functions, zcalc, zmv
- `zshcompwid` — completion widgets, compadd, special params, matching control, condition codes
- `zshcompsys` — compinit, compdef, zstyle, completers, autoload
- `stty` — terminal settings, control/input/output/local modes, control chars

Links:

- [XDG base dirs](https://specifications.freedesktop.org/basedir-spec/latest/)
