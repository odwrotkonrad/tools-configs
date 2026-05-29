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
            00-shell.zsh:
            10-tools.zsh:
            20-aliases.zsh:
            30-keybindings.zsh:
          functions/:
            fn_asdf_install:
            fn_install_kitty:
            fn_install_misc:
            fn_install_prometheus:
            fn_load_static_history:
            fn_ssh_generate_keys:
            fn_ssh_test_git_connection:
      root/usr/local/bin/:
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

- `zshzle` — line editor + bindkey widgets (rc.d/30-keybindings.zsh)
- `zshroadmap` — informal intro; pointers into the rest of the manual
- `zshparam` — special params (path, fpath, WORDCHARS, HIST\*) (rc.d/00-shell.zsh)
- `zshoptions` — setopt/unsetopt names (rc.d/00-shell.zsh)
- `zshmodules` — loadable modules (zmodload); backs zle, completion, stat/glob
- `zshexpn` — glob qualifiers `(on)`, `(N)`, `(:t)`, `(@kv)` used across rc.d
- `zshcontrib` — user-contributed functions + autoload patterns (functions/)
- `zshcompwid` — writing completion widgets
- `zshcompsys` — compinit / completion system (completions/)
- `zshbuiltins` — hash, typeset, setopt, fc, bindkey, autoload
- `zshall` — umbrella page; links the topic pages below
- `zsh` — overview, startup/shutdown file order
- `stty` — terminal cchars (rc.d/30-keybindings.zsh)

Links:

- [XDG base dirs](https://specifications.freedesktop.org/basedir-spec/latest/) — zshenv

