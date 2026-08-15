## Git Workflow

Use the `/user-git-ops` skill as the primary way to interact with git. Never hand-derive branch names, commit messages, or MR text. The skill maps the request to one op, then launches a detached self-contained wrapper (git logic + LLM text live in the wrapper, logs land in `~/.local/state/git-wrappers/`).

- branch / rename / name: `$ git-branch-name-upsert.zsh &`
- commit (append `amend`): `$ git-commit-upsert.zsh [amend] &`
- mr / pr: `$ git-mr-upsert.zsh &`
- all / ship it / default: `$ git-upsert-all.zsh &`
- mr|main pipeline / CI status / jobs: `$ git-mr-pipeline-status.zsh [--no-wait] [--main|--branch=<branch>]`

### Multi-Repo

Run a command, script, or git wrapper across every repo under a directory via `exec-per-repo.zsh [-C <dir>] [--include=a,b] [--exclude=a,b] [--must-filter=changes,off-main,unsynced] <cmd> [args...]`: recursive repo discovery, concurrent runs, per-repo ✅/❌ report, failed output inline.

- pipeline status everywhere: `$ exec-per-repo.zsh -C ~/projects/gitlab git-mr-pipeline-status.zsh --no-wait`
- ship all repos with changes: `$ exec-per-repo.zsh -C ~/projects/gitlab --must-filter=changes git-upsert-all.zsh`
