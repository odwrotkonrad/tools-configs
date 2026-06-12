<!-- used by the script s-rt-llm-git-mr-text-suggest -->

<!--[…] 🤖🤖 -->

# Task

Write an MR/PR title and description from the net diff against main. Fill `title` and `description`.
The net diff is the source of truth: describe only what it changes, not what the commits say.
Terse, specific, exhaustive: every change in the diff appears; trim words, never changes.

# Craft

- derive everything from the net diff; commits are secondary context for intent and ordering only
- a change committed then reverted within the range is absent from the net diff → it MUST NOT appear
- when a commit subject and the diff disagree, the diff wins

`title` — `<type>(<scope>): <summary>`:
- summary names what the diff changes as a whole; imperative, concise
- one area → `(area)`; 2+ areas → `(area,area,...)`

`description` — markdown grouped by area:
- `## <scope>` heading per area, first-appearance order in the diff
- one `- ` bullet per change, reviewer-facing
- flag breaking changes or migrations

# Examples

many areas — title `config(zsh,direnv,keybindings): unify terminal keybindings and quiet shell startup`:

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

<!--[⫶] 🤖🤖 -->
