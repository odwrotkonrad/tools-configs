---
paths:
  - "**/zsh/**"
  - "**/zshrc"
  - "**/zshenv"
  - "**/zlogin"
  - "**/zprofile"
  - "**/zlogout"
  - "**/*.zsh"
  - "**/installs/s-rt-*"
---

## ZSH Code

### Do

Use alternate forms for complex commands `$ man zshmisc (ALTERNATE FORMS)`
- `if list { list } [ elif list { list } ] ... [ else { list } ]`
- `if list sublist`

```
if { test } { cmd }
if (( ${+param} )) cmd
if (( ! ${+param} )) cmd
```
