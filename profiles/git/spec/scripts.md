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
  And with no main pipeline `## Pipeline Status` prints `none`, exits 0

Scenario: pipeline verdict is the exit code
  Status: implemented
  When the report finishes
  Then it exits 0 when the pipeline status is success, or no pipeline/MR exists
  And exits 1 on any other status (failed, canceled, running via --no-wait), so multi-repo runs flag it ❌

Scenario: branch main implies --main
  Status: implemented
  When I run with `--branch=main`, or from the main branch with no flags
  Then it behaves as `--main`
  And `--main` with any other `--branch` exits 2: `--main excludes --branch`

Feature: exec-for-all-repos.zsh

Scenario: fans a command out over every repo under a directory
  Status: implemented
  Given repos nested at any depth under a root directory
  When I run `exec-for-all-repos.zsh [-C <dir>|--chpwd=<dir>] <command> [args...]`
  Then repos are discovered recursively from `<dir>` (default pwd) by their `.git` entry (dir or worktree file)
  And `<dir>` itself being a repo is included, named by its basename
  And the command runs once per repo, cwd set to the repo, all repos concurrently in the background
  And each repo's stdout+stderr is captured to `~/.local/state/git-wrappers/exec-for-all-repos/<relative path, / → __>.log`, truncated per run
  And `GIT_WRAPPER_FG=1` is exported so git-*-upsert wrappers mirror their log into the capture

Scenario: arbitrary command with arguments
  Status: implemented
  When I run `exec-for-all-repos.zsh -C <dir> git status -sb`
  Then everything after the options is executed verbatim as `<cmd> [args...]` in each repo

Scenario: per-repo ✅/❌ report closes the run
  Status: implemented
  When all background runs finish
  Then a `## Report` section lists every repo in discovery order as `<repo>: ✅` or `<repo>: ❌ (exit N)`
  And each failed repo's captured output prints below under `## Output: <repo>`
  And the script exits 0 when all succeeded, 1 otherwise

Scenario: --include/--exclude select repos by name or path
  Status: implemented
  When I run with `--include=a,b` and/or `--exclude=c,d`
  Then a token containing `/` matches the repo path relative to the root exactly
  And a bare token matches the repo directory basename
  And include empty means all repos, exclude is applied after include
  And a basename matching more than one discovered repo exits 2, listing the candidates

Scenario: --must-filter targets repos needing attention, AND semantics
  Status: implemented
  When I run with `--must-filter=changes,off-main,unsynced` (any subset)
  Then only repos satisfying every listed condition run:
  And `changes`: `git status --porcelain` non-empty (tracked or untracked)
  And `off-main`: current branch is not `main`
  And `unsynced`: no upstream, or ahead/behind counts vs `@{u}` differ from `0 0`

Scenario: bad invocation exits 2 with usage
  Status: implemented
  When I pass an unknown option, or no command after the options
  Then usage prints on stderr and the script exits 2
<!--[<] 🤖🤖 -->
