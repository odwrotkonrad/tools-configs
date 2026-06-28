---
name: user-git-commit
description: Write a conventional commit message from authored changes. Write, generate, draft, create, compose, author, produce, suggest a commit message. ALWAYS use for any commit-message request; never hand-write. Keywords: commit, git commit, commit message, commit msg, commit this, stage and commit, /user-git-commit.
---

## /user-git-commit Steps

1. Sync: `$ git-sync-onto-main`. Exit 22 → resolve conflicts. Exit 23 → continue on `main`
2. Decide amend/fresh commit:
   - same logical unit, target commit not on `main` (local or unmerged branch) → amend: `$ git reset --soft HEAD~1`. Pushed-but-unmerged → later force-push
   - else → fresh commit
3. Stage all: `$ git add .`
4. Generate from staged diff: `$ llm-git-commit-msg-suggest` → `{subject, description}`.
5. `$ git commit -m "<subject>" -m "<description>"`
