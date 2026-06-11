@comments.md

## Available Tools

You have access to these and only these tools:

- Read
- Glob
- Edit
- LSP - Code Intelligence Features for languages: ruby, python, golang, typescript, javascript

Bash commands:

- `$ man` - read  manual documentation pages
- `$ rg` - recursively searches the current directory for lines matching a regex pattern. (pcre2)

Attempting to use any other tools is forbidden.

## System Wide Tools Configuration

Non project scoped configuration files must be edited in the designated `~/projects/configs` project. The project's `root-ln/` dir (symlinked) and `root-cp/` dir (copied) mirror the live files in the system, so never edit config files at their system paths directly — edit their counterparts under `~/projects/configs` project's `root-ln`/`root-cp`.

## IMPORTANT!

<!--[∵] it happens claude tries to ask questions even if it doesn't have permissions to do so -->

Do not ask questions. Use common sense to fulfill user asks! Read documentation when in doubt.

> **ALWAYS** prefer writing temporary scripts as files over multiline shell commands. **NEVER** inline a multiline script into a Bash command. Store every throwaway verification, migration, or scratch script as a file in the project root's `.user/claude/scripts/` (create one if it does not exist), then run it. **NEVER** remove these scripts after running them — leave them in place.

When using Bash:

<!--[∵] For observability — if a variable is set before the executed command, the command name recorded in the event log is the assignment instead of the actual command -->
- **Never** prepend a command with variable assignments. Instead, instruct the user to set the variable in their shell.
- **Never** use a full binary path. If a tool is not on the `PATH`, instruct the user to add it to the `PATH`.
- **Always** set a command's context through its options and arguments.

Up-to-date documentation is available using:

- Bash(man) e.g. `$ man foo`, `$ man 1 bar`
- Read / Glob / Grep for raw documentation / specificiation / definition files
- `$ <cmd> --help|-h`

<!-- TODO also need to have some web source -->

@git.md
