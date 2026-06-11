---
name: ko-git-mr-upsert
description: Create or update the MR/PR with a title and description from branch commits. Open, raise, create, update, upsert, submit, push, write, generate, draft an MR/PR. ALWAYS use for any MR/PR request; never hand-write the text. Keywords: MR, PR, merge request, pull request, open PR, raise MR, update MR, PR description, MR description, /ko-git-mr-upsert.
---

<!--[…] 🤖🤖 -->

## /ko-git-mr-upsert

Generate the title + description, then create/update the MR/PR via the provider CLI. Args after the command → `<additional-runtime-instructions>`.

1. Branch step: `ko-git-branch-name-upsert` skill. Rename if inaccurate; always rename a `tmp/...` branch — never open an MR/PR from one.
2. `s-ko-llm-git-mr-text-suggest main..HEAD "<additional-runtime-instructions>"` → JSON `{title, description}`.
3. CLI from `git remote get-url origin`: gitlab.com → `glab`, github.com → `gh`.
4. Push branch if needed, then (confirm first):
   - gitlab: `glab mr create`, or edit existing
   - github: `gh pr create`, or `gh pr edit`

<!--[⫶] 🤖🤖 -->
