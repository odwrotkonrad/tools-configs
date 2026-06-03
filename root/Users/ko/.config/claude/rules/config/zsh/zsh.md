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
      root/Users/ko/.config/zsh/:
        .zshenv:
        .zprofile:
        .zshrc:
        .zlogin:
        .zlogout:
        .zclaude:
        completions/:
        functions/:
        rc.d/:
          00-dirs.zsh:
          10-tools.zsh:
      root/etc/:
        zshenv:
        zprofile:
        zshrc:
        zlogin:
        zlogout:
        zsh/:
          static_history: # static history items loaded for each shell
          completions/:
          rc.d/:
            00-dirs.zsh:
            10-shell.zsh:
            20-tools.zsh:
            30-aliases.zsh:
            40-keybindings.zsh:
            50-hooks.zsh:
          functions/:
            rm:
            fn_load_static_history:
            fn_ssh_generate_keys:
            fn_ssh_test_git_connection:
      root/usr/local/scripts/:
        s_install_asdf:
        s_install_kitty:
        s_install_misc:
        s_install_prometheus:
        s_load_configs:
        s_load_defaults_config:
```

### Startup Order

`${ZDOTDIR}` = `~/.config/zsh` (the zsh config dir).

| # | File                          | Shells                  |
| - | ----------------------------- | ----------------------- |
| 1 | /etc/zshenv                   | all                     |
| 2 | ${ZDOTDIR}/.zshenv            | all                     |
| - | ${ZDOTDIR}/.zclaude           | Claude (custom)         |
| 3 | /etc/zprofile                 | login                   |
| 4 | ${ZDOTDIR}/.zprofile          | login                   |
| 5 | /etc/zshrc                    | interactive             |
| 6 | ${ZDOTDIR}/.zshrc             | interactive             |
| 7 | /etc/zlogin                   | login                   |
| 8 | ${ZDOTDIR}/.zlogin            | login                   |
| - | ${ZDOTDIR}/.zlogout           | login shell exit (1st)  |
| - | /etc/zlogout                  | login shell exit (2nd)  |

`/etc/zshrc` sources `/etc/zsh/rc.d/*.zsh` then autoloads `/etc/zsh/functions/*`; `.zshrc` sources `${ZDOTDIR}/rc.d/*.zsh`.

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

- [XDG base dirs](https://specifications.freedesktop.org/basedir-spec/latest/) — zshenv
