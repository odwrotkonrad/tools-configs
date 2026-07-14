---
paths:
  - "**/zsh/**"
  - "**/zshrc"
  - "**/zshenv"
  - "**/zlogin"
  - "**/zprofile"
  - "**/zlogout"
  - "**/*.zsh"
  - "**/installs/*"
---

## ZSH Code

Use alternate forms for complex commands. `$ man zshmisc (ALTERNATE FORMS)`

- `if list { list } [ elif list { list } ] ... [ else { list } ]`
- `if list sublist`

```
if { test } { cmd }
if (( ${+param} )) cmd
if (( ! ${+param} )) cmd
```
