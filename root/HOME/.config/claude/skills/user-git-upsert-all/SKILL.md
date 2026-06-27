---
name: user-git-upsert-all
description: Run the full git workflow end to end (branch, commit, MR/PR) by invoking the three user-git skills in order. Ship it, do the whole git flow, branch+commit+MR, upsert everything, finish the git work. Use for the complete sequence in one step. Keywords: upsert all, git all, full git flow, branch commit mr, ship it, do the git workflow, /user-git-upsert-all.
---

## /user-git-upsert-all Steps

Run the full git workflow in order.

1. Upsert branch: run skill `/user-git-branch-name-upsert`
2. Commit: run skill `/user-git-commit`
3. Upsert MR: run skill `/user-git-mr-upsert`
