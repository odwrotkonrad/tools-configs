## Style

{{ renderMarkdown "~/.config/claude/rules/docs/prose.md" "remove-frontmatter" "strip-comments" "normalize-headings" }}

## Task

Write an MR/PR title and description from the commit messages against main. Fill `title` and `description`.
The commit messages are the source of truth: describe what they change. The diff stats are context for scope and size only.

CRITICALLY IMPORTANT: branch commits iterate: later commits rework, rename, move, revert earlier ones. Describe the net effect against main only. Never mention a superseded change. Collapse iteration chains into their end state.
Describe the branch as one single change against main. A later commit "changes"/"renames"/"moves" something an earlier branch commit introduced → it was never in main → state it as added in its final form ("add ⚙️ manual emoji", not "change manual emoji to ⚙️"). Use change/rename/move/fix only against state present in main.

CRITICALLY IMPORTANT: no list over ~6 bullets, anywhere. Oversized `### <scope>` → split into `#### <feature>` subsections. Oversized `####` → split into finer sibling `####`s. One catch-all `####` is as invalid as a flat area, flat base included: regroup, keep bullet wording. A feature = one capability (a subcommand, a config key, a rename), never the whole change.

Terse, specific, exhaustive: every change that survives to the final state appears, trim words, never changes.
One line per bullet. No prose, no wrap-around. Drop nothing that survives, drop everything superseded.
State what changed. Never why. Never explain, justify, or guess.

- superseded changes (overwritten, renamed, reverted by a later commit) never appear, even when a commit message states them
- current description present → treat as base. Scale edits to change size: large change may rewrite, small change modifies in place, preserve existing wording, structure, bullet order. Add or adjust bullets only for what the commits change. Exception: a flat base area over ~6 bullets MUST be regrouped into `#### <feature>` subsections, keep bullet wording
- a base bullet describing a state later commits superseded is stale: rewrite it to the final state as one added change, never keep or append the intermediate step
- current description empty (first create) → write fresh from the commit messages
- never write a `## Commits` or `## Changes` heading, the tool injects them: emit only the `### <scope>` groups

`title` → `<type>(<scope>): <summary>`:
- summary names what the commits change as a whole, imperative, concise
- one area → `(area)`, 2+ areas → `(area,area,...)`

`description` → markdown grouped by area:
- `### <scope>` heading per area, first-appearance order in the commits
- over ~6 bullets → `#### <feature>` subsections, one per feature, at both `###` and `####` level: split finer instead of growing a list
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

big area, two features → title `feat(zsh): add deep-history widget and recency-sorted completion`:

```
### zsh

#### deep-history widget
- add ctrl+r widget searching merged local+global history
- dedupe entries, newest first
- bind in zle, kitty, vscode terminals

#### completion recency
- sort file completion candidates by mtime
- zstyle file-sort modification for files, keep dirs alphabetical
- add spec scenario for recency order, status implemented
```

one big feature → sub-features, no catch-all → title `feat(che): add packages command family`:

```
### che

#### install subcommand
- add `che packages install [pkg...]`, no args installs every profile's include.installPackages
- add --update, --if-missing, --packages-file, --packages-override flags
- resolve managers in rounds: one installed earlier serves later packages

#### check subcommands
- add check-present, check-upgradable, check-not-shadowed, check-single-present
- check-present auto-runs after a real install, warn-only

#### builtin packages.yml
- embed a builtin packages database, used when no packages file exists
- pin every entry to an exact version, sha256 per platform on archives

#### spec wiring
- add include.installPackages to profile specs, ordered before run-scripts
- add install-packages to --skip-ops values
```
{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}

## Context

### Current Description
{{ getenv "CURRENT_DESCRIPTION" }}

### Diff Stats
{{ getenv "DIFF_STATS" }}
{{ with getenv "FILES_AUTOGENERATED" }}
### Autogenerated Files

Regenerated renders, in the range but excluded from the diff stats above.
Never mention them in title or description.

{{ . }}
{{ end }}

## Data - source of truth

### Commit Messages
{{ getenv "COMMIT_BODIES" }}
