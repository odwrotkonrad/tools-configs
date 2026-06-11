---
name: ko-git-branch-name-upsert
description: Create or rename the branch to a conventional name derived from its commits. Create, rename, switch, make, set, fix, name a branch. ALWAYS use for any branch creation or naming request; never hand-derive the name. ALWAYS used by /ko-git-commit and /ko-git-mr-upsert for their branch step. Keywords: create branch, new branch, rename branch, branch name, what to call this branch, /ko-git-branch-name-upsert.
---

## /ko-git-branch-name-upsert

Upsert the branch to the suggested name. Args after the command → `<additional-runtime-instructions>`.

1. `s-ko-llm-git-branch-name-suggest main..HEAD "<additional-runtime-instructions>"` → JSON `{name}`.
2. Upsert vs current (`git rev-parse --abbrev-ref HEAD`), confirm before mutating:
   - on `main` → `git checkout -b <name>`
   - feature branch, different name → `git branch -m <name>`
   - already `<name>` → no-op
