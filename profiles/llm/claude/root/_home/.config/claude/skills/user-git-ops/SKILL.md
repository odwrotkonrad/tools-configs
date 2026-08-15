---
name: user-git-ops
description: Run a git op via a detached self-contained wrapper (branch, commit, MR/PR, or the full flow). Create, rename, switch, name a branch; write, generate, draft a commit message; open, raise, create, update, submit an MR/PR; or ship the whole flow end to end. Reports MR and main pipeline status. ALWAYS use for any branch-name, commit-message, MR/PR, or pipeline-status request; never hand-derive text, never hand-query pipelines. Keywords: create branch, new branch, rename branch, branch name, commit, git commit, commit message, commit msg, stage and commit, MR, PR, merge request, pull request, open PR, raise MR, update MR, MR description, PR description, upsert all, full git flow, branch commit mr, ship it, do the git workflow, pipeline, pipeline status, CI status, jobs status, is CI green, /user-git-ops.
---

## /user-git-ops Steps

Map the request to one op, then run it detached (logic + LLM text live in the
wrapper, tail `~/.local/state/git-wrappers/<wrapper>.log` if needed):

- branch / rename / name        → `$ git-branch-name-upsert.zsh &`
- commit (append `amend` arg)    → `$ git-commit-upsert.zsh [amend] &`
- mr / pr                        → `$ git-mr-upsert.zsh &`
- all / ship it / (default)      → `$ git-upsert-all.zsh &`
- mr|main pipeline / CI status / jobs    → `$ git-mr-pipeline-status.zsh [--no-wait] [--main|--branch=<branch>]`
