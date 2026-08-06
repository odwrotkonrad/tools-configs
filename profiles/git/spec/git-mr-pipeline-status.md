<!--[>] 🤖🤖 -->
Feature: git-mr-pipeline-status.zsh

Scenario: finds the MR you are working on, no arguments needed
  Status: implemented
  When I run `git-mr-pipeline-status.zsh [--branch=<branch>]`
  Then it picks the open MR from the given branch, default current branch
  And falls back to the most recently updated open MR
  And with no open MRs prints `no open MRs`, exits 0

Scenario: one readable report answers "how is my MR doing"
  Status: implemented
  When the report prints
  Then sections are ANSI-bold markdown: `# MR: !iid`, `## Repo`, `## Branch`, `## Stages`, `## Pipeline Status`
  And `# MR` lists `name:`, `url:`, `pipeline-url:`
  And `## Repo` lists `repo:`, `url:`, `open mr count: 1`
  And `## Pipeline Status` closes the report with only the status line
  And every url carries a `url: ` designator

Scenario: forgotten open MRs surface before they go stale
  Status: implemented
  Given more than 1 open MR
  Then `## Repo` swaps the count line for a `### ⚠️ Open MR count: N` subsection
  And it lists every open MR as `name:`, `url:`, `update-time:`, recency order
  And the selected branch's MR is first, marked `current: true`

Scenario: unpushed, unpulled and unmerged work is visible before review
  Status: implemented
  When the `## Branch` section prints
  Then it lists the branch name, then after a fetch:
  And `origin - local:` ✅ synced, or ⚠️ local ahead (N) / remote ahead (N) / diverged / missing local or origin branch
  And `line changes: +adds -dels (~files files)` vs main
  And `commit count:` commits not in main

Scenario: slow pipeline stages stand out via wall time
  Status: implemented
  When the `## Stages` section prints
  Then stages follow pipeline order, headed `### <stage> <wall time>`
  And wall time = max finished_at - min started_at over the stage's jobs (now when unfinished), omitted when none ran
  And each job entry is `<emoji> <duration> <name>`, `url:` below, blank line between
  And manual jobs append ` (manual trigger)`, canceled jobs ` (canceled)`

Scenario: job status readable at a glance, columns aligned
  Status: implemented
  Then emoji: ✅ success, ❌ failed, 🚫 canceled, ⏭️ skipped, ⚙️ manual, 🕐 running, ⏳ otherwise
  And durations are fixed-width `MMmSSs`, space-padded minutes, up to 1h
  And `-` when the job has not run

Scenario: blocks until the CI verdict, streaming job progress
  Status: implemented
  Given the head pipeline is in progress
  When I run without flags (or `--wait`)
  Then it polls every 10s until the pipeline fails or succeeds
  And a bold `## Inprogress Log` header opens the stream after `## Branch`
  And each completed job prints once to stderr: `done: <emoji> <duration> <name>`
  And each poll prints `waiting: <running jobs with elapsed>`, `no job running yet` when none

Scenario: --no-wait takes an instant snapshot mid-run
  Status: implemented
  Given the head pipeline is in progress
  When I run with `--no-wait`
  Then it reports at once
  And running jobs show 🕐 with elapsed since start

Scenario: --main reports the latest main pipeline
  Status: implemented
  When I run with `--main`
  Then MR and branch sections are skipped, `## Repo` prints as usual
  And it picks the latest push-sourced main pipeline (merge into main), other sources skipped
  And a `# Main Pipeline` header lists `url:`, `sha:`
  And `## Stages`, `## Pipeline Status`, wait polling behave as for an MR
  And with no main pipeline `## Pipeline Status` prints `none: <reason>`, exits 0

Scenario: pipeline verdict is the exit code
  Status: implemented
  When the report finishes
  Then it exits 1 only when the pipeline errored (failed or canceled), so multi-repo runs flag it ❌
  And exits 0 on any other status: success, still running via --no-wait, manual/blocked, no open MRs
  And no pipeline exits 0 with a `none: <reason>` line naming what was missing

Scenario: branch main implies --main
  Status: implemented
  When I run with `--branch=main`, or from the main branch with no flags
  Then it behaves as `--main`
  And `--main` with any other `--branch` exits 2: `--main excludes --branch`
<!--[<] 🤖🤖 -->
