---
name: ko-git-mr-upsert
description: Create or update the MR/PR with a title and description from branch commits. Open, raise, create, update, upsert, submit, push, write, generate, draft an MR/PR. ALWAYS use for any MR/PR request; never hand-write the text. Keywords: MR, PR, merge request, pull request, open PR, raise MR, update MR, PR description, MR description, /ko-git-mr-upsert.
---

## /ko-git-mr-upsert Steps

1. Always run skill `/ko-git-branch-name-upsert` (syncs onto main, names the branch). If it leaves you on `main` (branch was merged, no new commits) → stop, report nothing to MR
2. Always push the branch by decision tree:
   - history rewritten (rebased by step 1, or amended an already-pushed commit) → `$ git push --force-with-lease -u origin HEAD`
   - else → `$ git push -u origin HEAD`
3. Generate: `$ s-rt-llm-git-mr-text-suggest` → `{title, description}` from `main...HEAD`.
4. Pick CLI from `git remote get-url origin`: gitlab.com → `glab` | github.com → `gh`.
5. Upsert MR:
   - no open MR → create
   - open MR →
    - same source branch → edit text: update
    - changed source branch → close + create
