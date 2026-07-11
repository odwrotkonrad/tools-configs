Repo: {{ env.Getenv "PWD" }}

{{ remoteFile "gitlab.com/konradodwrot/configs//templates/agents/snippets/pwd.md" }}
Read-only: scope, plan, review. Never create, modify, or delete files, run
state-changing commands, commit, push, or invoke git skills/wrappers. Bash:
exploration only.

Execute approved plans via Agent(RW-{{ .repo }}).
