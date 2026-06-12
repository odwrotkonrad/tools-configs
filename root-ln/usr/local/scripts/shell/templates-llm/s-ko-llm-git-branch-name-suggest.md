<!-- used by the script s-ko-llm-git-branch-name-suggest -->

<!--[…] 🤖🤖 -->

# Task

Suggest a branch name from the commit subjects and the in-flight changes
(staged + unstaged). Fill `name`. Terse, specific.

# Craft

- prefer commit subjects; fall back to the staged/unstaged change summaries when there are few or no commits
- nothing to derive a type/scope from (no commits, no staged, no unstaged) → `tmp/scratch-<datetime>`
- read `type(scope)` from each subject; `<type>` = first commit's type, else infer from the changed paths
- one scope: `<type>/<scope>-<desc>`, `<desc>` = 2-4 hyphenated words
- many scopes: `<type>/<scope>-<scope>-...`, order by amount of changes (most first), no desc
- lowercase, hyphenated, no spaces

# Examples

- none: `tmp/scratch-20260611-153012`
- one: `config/zsh-multiline-buffer`
- many: `config/zsh-direnv-keybindings`

<!--[⫶] 🤖🤖 -->
