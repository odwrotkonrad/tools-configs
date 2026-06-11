<!-- used by the script s-ko-llm-git-mr-text-suggest -->

# Task

Write an MR/PR title and description from the commits. Fill `title` and `description`.
Terse, specific, exhaustive: every change appears; trim words, never changes.

# Craft

`title` — `<type>(<scope>): <summary>`:
- summary names what the branch changes as a whole; imperative, concise
- one area → `(area)`, NEVER `batch`; only 2+ areas use `batch,<area>,<area>,...`

`description` — markdown grouped by area:
- `## <scope>` heading per area, first-appearance order
- one `- ` bullet per change, `type(scope): ` prefix stripped, reviewer-facing
- flag breaking changes or migrations

# Examples

many areas — title `config(batch,zsh,direnv,keybindings): unify terminal keybindings and quiet shell startup`:

```
## zsh
- multiline buffer on trailing backslash, alt+enter inserts newline
- split zle widgets into their own rc.d file

## direnv
- silence load and unload logs

## keybindings
- bind ctrl+; to execute-named-command across zle, kitty, vscode
```

one area — title `config(zsh): restructure zle widgets and naming`:

```
## zsh
- move zle widgets into 31-zle-widgets.zsh, registered via a wd_fn_rt array
- rename widget functions to the wd-fn-rt-* namespace
- rename keystroke sequences from s_seq to rt_seq
```
