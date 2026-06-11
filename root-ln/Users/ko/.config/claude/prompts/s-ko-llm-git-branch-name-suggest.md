<!-- used by the script s-ko-llm-git-branch-name-suggest -->

# Task

Suggest a branch name from the commit subjects. Fill `name`. Terse, specific.

# Craft

- no commits in range → `tmp/scratch-<datetime>` (nothing to derive a type/scope from)
- read `type(scope)` from each subject; `<type>` = first commit's type
- one scope: `<type>/<scope>-<desc>`, `<desc>` = 2-4 hyphenated words
- many scopes: `<type>/<scope>-<scope>-...`, first-appearance order, no desc
- lowercase, hyphenated, no spaces

# Examples

- none: `tmp/scratch-20260611-153012`
- one: `config/zsh-multiline-buffer`
- many: `config/zsh-direnv-keybindings`
