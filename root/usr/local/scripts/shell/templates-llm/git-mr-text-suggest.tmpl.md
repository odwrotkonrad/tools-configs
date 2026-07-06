## Style

{{ renderMarkdown "~/.config/claude/rules/docs/prose.md" "remove-frontmatter" "strip-comments" "normalize-headings" }}

## Task

Write an MR/PR title and description from the commit messages against main. Fill `title` and `description`.
The commit messages are the source of truth: describe what they change. The diff stats are context for scope and size only.
Terse, specific, exhaustive: every change the commits state appears, trim words, never changes.
One line per bullet. No prose, no wrap-around. Drop nothing.
State what changed. Never why. Never explain, justify, or guess.

- derive everything from the commit messages, the diff stats are secondary context for scope and size only
- current description present → treat as base. Scale edits to change size: large change may rewrite, small change modifies in place, preserve existing wording, structure, bullet order. Add or adjust bullets only for what the commits change
- current description empty (first create) → write fresh from the commit messages
- never write a `## Commits` or `## Changes` heading, the tool injects them; emit only the `### <scope>` groups

`title` → `<type>(<scope>): <summary>`:
- summary names what the commits change as a whole, imperative, concise
- one area → `(area)`, 2+ areas → `(area,area,...)`

`description` → markdown grouped by area:
- `### <scope>` heading per area, first-appearance order in the commits
- one `- ` bullet per change, reviewer-facing
- flag breaking changes or migrations

## Examples

many areas → title `config(zsh,direnv,keybindings): unify terminal keybindings and quiet shell startup`:

```
### zsh
- multiline buffer on trailing backslash, alt+enter inserts newline
- split zle widgets into their own rc.d file

### direnv
- silence load and unload logs

### keybindings
- bind ctrl+; to execute-named-command across zle, kitty, vscode
```

one area → title `config(zsh): restructure zle widgets and naming`:

```
### zsh
- move zle widgets into 31-zle-widgets.zsh, registered via a wd_fn_rt array
- rename widget functions to the wd-fn-root-* namespace
- rename keystroke sequences from s_seq to rt_seq
```
{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}

## Context

### Current Description
{{ getenv "CURRENT_DESCRIPTION" }}

### Diff Stats
{{ getenv "DIFF_STATS" }}

## Data - source of truth

### Commit Messages
{{ getenv "COMMIT_BODIES" }}
