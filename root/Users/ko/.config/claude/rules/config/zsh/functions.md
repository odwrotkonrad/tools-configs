---
paths:
  - "**/zsh/functions/**"
---

## ZSH Functions

Autoloaded by `/etc/zshrc`. Filename = function name (`rm` shadows the command; `fn-rt-*` called as-is).

Every function starts with `emulate -LR zsh`.
- -R - Reset shell options to defaults for the function (for portability, it will work regardless of options set by the shell)
- -L - sets `LOCAL_OPTIONS`/`LOCAL_PATTERNS`/`LOCAL_TRAPS` so option/trap changes are function scoped
