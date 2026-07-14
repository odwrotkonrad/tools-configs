## Git Workflow

Use the `/user-git-ops` skill as the primary way to interact with git. Never hand-derive branch names, commit messages, or MR text. The skill maps the request to one op, then launches a detached self-contained wrapper (git logic + LLM text live in the wrapper; logs land in `~/.local/state/git-wrappers/`).

- branch / rename / name: `$ git-branch-name-upsert.zsh &`
- commit (append `amend`): `$ git-commit-upsert.zsh [amend] &`
- mr / pr: `$ git-mr-upsert.zsh &`
- all / ship it / default: `$ git-upsert-all.zsh &`
