<!--[…] 🤖🤖 -->

## Git Workflow

`ko`-namespaced skills, text-only via `claude -p`. Don't push unasked. Each calls a script (links below); conventions live in the script's prompt md file.

### /ko-git-upsert-all — run the whole flow

Invokes the three skills in order: `/ko-git-branch-name-upsert` → `/ko-git-commit` → `/ko-git-mr-upsert`. Stops on any failure or declined confirmation; each step keeps its own confirmations.

### /ko-git-commit — commit message from staged diff

- in → out: staged diff + `<additional-runtime-instructions>` → `{subject, description}`
- [script](../../../../usr/local/scripts/shell/s-ko-llm-git-commit-msg-suggest) · [craft](prompts/s-ko-llm-git-commit-msg-suggest.md)
- commit vs amend: pushed HEAD or different logical unit → new commit; else → `git commit --amend`

### /ko-git-branch-name-upsert — create/rename branch to a conventional name

Used by `/ko-git-commit` and `/ko-git-mr-upsert` for their branch step.

- in → out: commits + staged/unstaged changes → `{name}`; then `git checkout -b` (on base) or `git branch -m` (rename)
- [script](../../../../usr/local/scripts/shell/s-ko-llm-git-branch-name-suggest) · [craft](prompts/s-ko-llm-git-branch-name-suggest.md)

### /ko-git-mr-upsert — create/update the MR/PR

- in → out: `main...HEAD` net diff (commits = secondary context) → `{title, description}`; then create/update via the provider CLI
- [script](../../../../usr/local/scripts/shell/s-ko-llm-git-mr-text-suggest) · [craft](prompts/s-ko-llm-git-mr-text-suggest.md)
- CLI from `git remote get-url origin`: gitlab.com → `glab mr create`/edit, github.com → `gh pr create`/`gh pr edit`

<!--[⫶] 🤖🤖 -->
