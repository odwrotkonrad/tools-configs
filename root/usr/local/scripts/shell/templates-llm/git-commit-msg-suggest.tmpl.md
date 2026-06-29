## Data

### Full Diff
{{ getenv "DIFF_FULL" }}

### Diff Stats
{{ getenv "DIFF_STATS" }}

### Commit Template
{{ getenv "COMMIT_TEMPLATE" }}

## Style

{{ renderMarkdown "--strip-frontmatter" "--strip-comments" "--increment-heading-levels" (printf "%s/.config/claude/rules/docs/prose.md" (env.Getenv "HOME")) | strings.TrimSpace }}

## Task

Write a commit message from the staged diff. Fill `subject` and `description`.
Terse, specific, exhaustive: every change appears, trim words, never changes.
Cut every point to one line. Drop nothing, restate nothing.
State what changed. Never why. Never explain, justify, or guess. Only what the diff shows.

`subject` → `<type>(<scope>): <summary>`:
- imperative, lowercase, <=72 chars, no trailing period
- names what changed, not the file. no filler ("update", "misc", "wip")
- one area → `(area)`, 2+ areas → `(area,area,...)`

`description` → the body:
- what each change does, concretely. wrap ~72 cols, flag breaking changes
- multi-area change → group under an `area:` heading per area

## Examples

one area → `config(direnv): silence load and unload logs`:

```
Set log_format to empty so entering or leaving a directory no longer prints
the "direnv: loading" / "direnv: unloading" lines.
```

many areas → `config(zsh,kitty,vscode): bind ctrl+shift+z to foreground the last job`:

```
zsh:
add a zle widget that pushes the chord and runs `fg %-`

kitty:
map ctrl+shift+z to send the escape the widget reads

vscode:
add the keybinding so the integrated terminal matches
```
{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}
