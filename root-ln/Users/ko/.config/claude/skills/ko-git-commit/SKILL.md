---
name: ko-git-commit
description: Write a conventional commit message from authored changes. Write, generate, draft, create, compose, author, produce, suggest a commit message. ALWAYS use for any commit-message request; never hand-write. Keywords: commit, git commit, commit message, commit msg, commit this, stage and commit, /ko-git-commit.
---

## /ko-git-commit Steps

1. Decide amend/fresh commit:
   - same logical unit, target commit not on `main` (local or unmerged branch) → amend: `$ git reset --soft HEAD~1`. Pushed-but-unmerged → later force-push
   - else → fresh commit
2. Stage all: `$ git add .`
3. Generate from staged diff: `$ s-rt-llm-git-commit-msg-suggest` → `{subject, description}`.
4. `$ git commit -m "<subject>" -m "<description>"`
