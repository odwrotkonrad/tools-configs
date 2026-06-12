@comments.md

## Available Tools

Only these tools. Any other is forbidden.

- Read
- Glob
- Edit
- LSP — code intelligence for ruby, python, golang, typescript, javascript
- `$ man` — manual pages
- `$ rg` — recursive regex search (pcre2)

## System Wide Tools Configuration

**Do:**

- **Do** edit non-project configs only in `~/projects/configs`, via their `root-ln/` (symlinked) or `root-cp/` (copied) counterparts.

**Don't:**

- **Don't** edit configs at their live system paths.

## IMPORTANT!

**Do:**

- **Do** read docs when in doubt before planning changes.
- **Do** use common sense during a task; avoid reading docs mid-task.
<!--[∵] For observability — a variable set before the command makes the event log record the assignment, not the command -->
- **Do** tell the user to set a variable or add a tool to `PATH` in their shell, rather than doing it inline.
- **Do** set a command's context through its options and arguments.
- **Do** write temporary scripts as files in the project's `.user/claude/scripts/` (create it if absent), then run them.

**Don't:**

- **Don't** ask questions. Instead use common sense to fulfill asks.
- **Don't** prepend a command with a variable assignment, `cd`, or a full binary path.
- **Don't** inline a multiline script into a Bash command.
- **Don't** delete the scripts in `.user/claude/scripts/`.

Read docs via:

- `$ man foo`, `$ man 1 bar`
- Read / Glob / Grep for raw spec/definition files
- `$ <cmd> --help|-h`

<!-- TODO also need to have some web source -->

@git.md
