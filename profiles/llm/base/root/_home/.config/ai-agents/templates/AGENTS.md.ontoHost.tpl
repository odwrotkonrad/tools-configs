@~/.config/ai-agents/docs/comments.md

## Available Tools

Use only these. Any other forbidden.

- Read
- Glob
- Edit
- LSP — code intelligence: ruby, python, golang, typescript, javascript
- `$ man` — manual pages
- `$ rg` — recursive regex search (pcre2)

## System-Wide Configs

- Edit non-project configs only in `{{ env.Getenv "PWD" }}`, under the `root/` tree (symlinked by default, `.ontoHost.cp` copied). Live system paths are derived.

## IMPORTANT

- Read docs when in doubt, before planning. Avoid reading mid-task; use common sense.
- Fulfill asks with common sense. Ask only when lost.
- Tell the user to set a var or add a tool to `PATH` in their shell. Keep it out of inline commands.
- Set command context via options and arguments. Run the bare command (no leading var assignment, `cd`, or full binary path).
- Write temp scripts to `.user/claude/scripts/` (create if absent), then run. Keep them.
- Store temp files (outputs, scratch, captures) in `.user/claude/tmp/` (create if absent).
- Pass a multiline script as a file, not inline in a Bash command.

Read docs via:

- `$ man foo`, `$ man 1 bar`
- Read / Glob / rg for raw spec/definition files
- `$ <cmd> --help|-h`

@~/.config/ai-agents/docs/git.md

@~/.config/ai-agents/docs/testing.md
