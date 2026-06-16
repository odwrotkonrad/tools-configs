---
name: ko-git-upsert-all
description: Run the full git workflow end to end (branch, commit, MR/PR) by invoking the three ko-git skills in order. Ship it, do the whole git flow, branch+commit+MR, upsert everything, finish the git work. Use for the complete sequence in one step. Keywords: upsert all, git all, full git flow, branch commit mr, ship it, do the git workflow, /ko-git-upsert-all.
---

## /ko-git-upsert-all Steps

Run the full git workflow in order.

1. Upsert branch: run skill `/ko-git-branch-name-upsert`
2. Commit: run skill `/ko-git-commit`
3. Upsert MR: run skill `/ko-git-mr-upsert`
