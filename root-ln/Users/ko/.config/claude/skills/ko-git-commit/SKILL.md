---
name: ko-git-commit
description: Write a conventional commit message from authored changes. Write, generate, draft, create, compose, author, produce, suggest a commit message. ALWAYS use for any commit-message request; never hand-write. Keywords: commit, git commit, commit message, commit msg, commit this, stage and commit, /ko-git-commit.
---

## /ko-git-commit

Commit the staged changes with the suggested message. Args after the command → `<additional-runtime-instructions>`.

1. Inspect: `git status --porcelain`, `git diff[ --cached]`.
2. Stage only changes you authored (`git add`); ask before staging others; multi-area → suggest splitting.
3. Branch step: `ko-git-branch-name-upsert` skill.
4. `s-ko-llm-git-commit-msg-suggest "<additional-runtime-instructions>"` → JSON `{subject, description}`.
5. Show the message, then commit it: `git commit -m "<subject>" -m "<description>"`.
