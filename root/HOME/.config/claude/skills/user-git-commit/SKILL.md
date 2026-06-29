---
name: user-git-commit
description: Write a conventional commit message from authored changes. Write, generate, draft, create, compose, author, produce, suggest a commit message. ALWAYS use for any commit-message request; never hand-write. Keywords: commit, git commit, commit message, commit msg, commit this, stage and commit, /user-git-commit.
---

## /user-git-commit Steps

1. Sync: `$ git-sync-onto-main.zsh`. Exit 22 → resolve conflicts. Exit 23 → on `main`; branch off first via `/user-git-branch-name-upsert` before any commit
2. Never commit to `main`. If `HEAD` is `main`, branch off (step 1) before proceeding.
3. Amend/fresh commit by arg:
   - no arg (default) → fresh commit
   - `amend` arg → amend: `$ git reset --soft HEAD~1`. Pushed-but-unmerged → later force-push. Guard: never amend a commit on `main`. If `HEAD` is on `main` (already merged), abort amend, branch off (step 1), fall back to fresh
4. Stage all: `$ git add .`
5. Generate from staged diff: `$ llm-git-commit-msg-suggest.zsh` → `{subject, description}`.
6. `$ git commit -m "<subject>" -m "<description>"`
