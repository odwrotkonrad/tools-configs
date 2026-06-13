<!--[…] 🤖🤖 -->

## Git Workflow

`ko`-namespaced skills, text-only via `claude -p`. Don't push unasked. Each calls a script (links below); conventions live in the script's prompt md file.

### /ko-git-upsert-all — run the whole flow

Invokes the three skills in order: `/ko-git-branch-name-upsert` → `/ko-git-commit` → `/ko-git-mr-upsert`. Stops on any failure or declined confirmation; each step keeps its own confirmations.

### /ko-git-commit — commit message from staged diff

- in → out: staged diff + `<additional-runtime-instructions>` → `{subject, description}`
- script: `s-rt-llm-git-commit-msg-suggest`
- commit vs amend: pushed HEAD or different logical unit → new commit; else → `git commit --amend`

### /ko-git-branch-name-upsert — create/rename branch to a conventional name

Runs before `/ko-git-commit`, and used by `/ko-git-mr-upsert` for its branch step.

- in → out: commits + staged/unstaged changes → `{name}`; then `git checkout -b` (on base) or `git branch -m` (rename)
- script: `s-rt-llm-git-branch-name-suggest`

### /ko-git-mr-upsert — create/update the MR/PR

- in → out: `main...HEAD` net diff (commits = secondary context) → `{title, description}`; then create/update via the provider CLI
- script: `s-rt-llm-git-mr-text-suggest`
- CLI from `git remote get-url origin`: gitlab.com → `glab mr create`/edit, github.com → `gh pr create`/`gh pr edit`

<!--[⫶] 🤖🤖 -->
