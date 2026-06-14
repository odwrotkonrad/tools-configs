---
paths:
  - "**/zsh/**functions"
---

## ZSH Functions

Autoloaded from `zsh/<phase>.d/functions/` (`zshenv.d` = all shells, `zshrc.d` = interactive). Filename = function name (`rm` shadows the command; `fn-rt-*` called as-is).

Tiny eager helpers wanted in every shell go inline in `zshenv.d/auto.d/00-functions.zsh` (defined at source time, e.g. `is-os`, `exit-with`). Larger or lazy functions get their own autoloaded file under `functions/`.

Every function starts with `emulate -LR zsh`.
- -R - Reset shell options to defaults for the function (for portability, it will work regardless of options set by the shell)
- -L - sets `LOCAL_OPTIONS`/`LOCAL_PATTERNS`/`LOCAL_TRAPS` so option/trap changes are function scoped
