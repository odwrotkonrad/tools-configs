---
name: user-git-branch-name-upsert
description: Create or rename the branch to a conventional name derived from its commits and in-flight changes (staged + unstaged). Create, rename, switch, make, set, fix, name a branch. ALWAYS use for any branch creation or naming request; never hand-derive the name. Runs before /user-git-commit. Keywords: create branch, new branch, rename branch, branch name, what to call this branch, /user-git-branch-name-upsert.
---

## /user-git-branch-name-upsert Steps

1. Sync onto main: `$ git-sync-onto-main`. Exit 22 (conflicts) → resolve conflicts. Exit 23 (merged, now on main) → continue
2. Generate: `$ llm-git-branch-name-suggest` → `{name}`
3. Upsert by current branch:
   - `main` → `$ git checkout -b <name>`
   - different name  → `$ git branch -m <name>`
