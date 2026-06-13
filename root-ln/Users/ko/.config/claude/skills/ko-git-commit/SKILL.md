---
name: ko-git-commit
description: Write a conventional commit message from authored changes. Write, generate, draft, create, compose, author, produce, suggest a commit message. ALWAYS use for any commit-message request; never hand-write. Keywords: commit, git commit, commit message, commit msg, commit this, stage and commit, /ko-git-commit.
---

<!--[…] 🤖🤖 -->

## /ko-git-commit

Commit the staged changes with the suggested message. Args after the command → `<additional-runtime-instructions>`.

1. Inspect: `git status --porcelain`, `git diff[ --cached]`.
2. Stage only changes you authored (`git add`); ask before staging others; multi-area → suggest splitting.
3. On `main` → `ko-git-branch-name-upsert` skill first; else commit on the current branch.
4. Amend vs new commit: if the change fixes/extends a commit not yet merged to `main` (still local or only on the unmerged feature branch) and is the same logical unit → amend. Else → new commit.
   - amend: `git reset --soft <commit>` to restage that commit + the new changes, regenerate the message from the full diff (step 5), then `git commit` to recreate it. A pushed-but-unmerged branch needs a later force-push.
   - never amend a commit already on `main`.
5. `printf '%s' "<additional-runtime-instructions>" | s-rt-llm-git-commit-msg-suggest` → JSON `{subject, description}`.
6. Show the message, then commit it: `git commit -m "<subject>" -m "<description>"`.

<!--[⫶] 🤖🤖 -->
