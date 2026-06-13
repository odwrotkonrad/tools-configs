---
name: ko-git-upsert-all
description: Run the full git workflow end to end — commit, then branch, then MR/PR — by invoking the three ko-git skills in order. Ship it, do the whole git flow, commit+branch+MR, upsert everything, finish the git work. Use when the user wants the complete sequence in one step rather than running each skill by hand. Keywords: upsert all, git all, full git flow, commit branch mr, ship it, do the git workflow, /ko-git-upsert-all.
---

<!--[…] 🤖🤖 -->

## /ko-git-upsert-all

Run the full git workflow in order. Args after the command → `<additional-runtime-instructions>`, forwarded to each step.

1. Commit step: `ko-git-commit` skill.
2. Branch step: `ko-git-branch-name-upsert` skill.
3. MR/PR step: `ko-git-mr-upsert` skill.

Run them in sequence, stopping if any step fails or the user declines a confirmation. Each skill keeps its own confirmations (staging, branch mutation, push). Don't push unasked beyond what `ko-git-mr-upsert` already confirms.

<!--[⫶] 🤖🤖 -->