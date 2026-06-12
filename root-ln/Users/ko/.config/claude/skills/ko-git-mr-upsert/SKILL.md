---
name: ko-git-mr-upsert
description: Create or update the MR/PR with a title and description from branch commits. Open, raise, create, update, upsert, submit, push, write, generate, draft an MR/PR. ALWAYS use for any MR/PR request; never hand-write the text. Keywords: MR, PR, merge request, pull request, open PR, raise MR, update MR, PR description, MR description, /ko-git-mr-upsert.
---

<!--[…] 🤖🤖 -->

## /ko-git-mr-upsert

Generate the title + description, then create/update the MR/PR via the provider CLI. Args after the command → `<additional-runtime-instructions>`. Title/description describe the net diff against main, not the commit messages.

1. Branch step: `ko-git-branch-name-upsert` skill. Rename if inaccurate; always rename a `tmp/...` branch — never open an MR/PR from one.
2. `printf '%s' "<additional-runtime-instructions>" | s-rt-llm-git-mr-text-suggest main..HEAD` → JSON `{title, description}` from the `main...HEAD` diff.
3. CLI from `git remote get-url origin`: gitlab.com → `glab`, github.com → `gh`.
4. Push branch if needed, then (confirm first). `create` = gitlab `glab mr create` / github `gh pr create`:
   - no open MR → create.
   - open MR, same source branch → edit text only: gitlab `glab mr update`, github `gh pr edit`.
   - open MR, changed source branch (renamed/force-pushed/retargeted) → never update the branch; close + create: gitlab `glab mr close <id>`, github `gh pr close <num>`.

<!--[⫶] 🤖🤖 -->
