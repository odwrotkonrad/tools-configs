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

Non project scoped configuration files must be edited in the designated `~/projects/configs` project. The project's `root/` dir mirrors and is linked to the live files in the system, so never edit config files at their system paths directly — edit their counterparts under `~/projects/configs` projects `root`.

## IMPORTANT!

<!--[∵] it happens claude tries to ask questions even if it doesn't have permissions to do so -->

Do not ask questions. Use common sense to fulfill user asks! Read documentation when in doubt.

Up-to-date documentation is available using:

- Bash(man) e.g. `$ man foo`, `$ man 1 bar`
- Read / Glob / Grep for raw documentation / specificiation / definition files
- `$ <cmd> --help|-h`

<!-- TODO also need to have some web source -->
