## Data

### Full Diff - source of truth
{{ getenv "DIFF_FULL" }}

### Full Diff Stats
{{ getenv "DIFF_STATS" }}

### Latest Commit
{{ getenv "LATEST_COMMIT" }}

## Style

{{ renderMarkdown "--strip-frontmatter" "--strip-comments" "--increment-heading-levels" (printf "%s/.config/claude/rules/docs/prose.md" (env.Getenv "HOME")) | strings.TrimSpace }}

## Task

Write an MR/PR title and description from the net diff against main. Fill `title` and `description`.
The net diff is the source of truth: describe only what it changes, not what the commit says.
Terse, specific, exhaustive: every change in the diff appears, trim words, never changes.
One line per bullet. No prose, no wrap-around. Drop nothing.
State what changed. Never why. Never explain, justify, or guess. Only what the diff shows.

- derive everything from the net diff, the latest commit is secondary context for intent only
- a change absent from the net diff MUST NOT appear, even if mentioned in the commit
- when the commit and the diff disagree, the diff wins

`title` → `<type>(<scope>): <summary>`:
- summary names what the diff changes as a whole, imperative, concise
- one area → `(area)`, 2+ areas → `(area,area,...)`

`description` → markdown grouped by area:
- `## <scope>` heading per area, first-appearance order in the diff
- one `- ` bullet per change, reviewer-facing
- flag breaking changes or migrations

## Examples

many areas → title `config(zsh,direnv,keybindings): unify terminal keybindings and quiet shell startup`:

```
## zsh
- multiline buffer on trailing backslash, alt+enter inserts newline
- split zle widgets into their own rc.d file

## direnv
- silence load and unload logs

## keybindings
- bind ctrl+; to execute-named-command across zle, kitty, vscode
```

one area → title `config(zsh): restructure zle widgets and naming`:

```
## zsh
- move zle widgets into 31-zle-widgets.zsh, registered via a wd_fn_rt array
- rename widget functions to the wd-fn-root-* namespace
- rename keystroke sequences from s_seq to rt_seq
```
{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}
