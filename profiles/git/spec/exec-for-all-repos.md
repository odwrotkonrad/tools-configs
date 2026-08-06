<!--[>] 🤖🤖 -->
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

Scenario: progress log streams per-repo completion with elapsed time
  Status: implemented
  Given repos running concurrently in the background
  When a repo's run finishes
  Then a `## Progress` section on stderr streams `done: <✅|❌> <M>m<SS>s <repo>` in finish order
  And elapsed counts from that repo's spawn to its finish
  And finishes are detected by polling every 1s, so lines appear as repos complete, not in discovery order

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

SubFeature: exec-for-all-repos.zsh completions

Scenario: first positional arg completes via the deep command engine
  Status: implemented
  Given the `_exec-for-all-repos` completion file is on fpath
  When I complete the first positional arg
  Then the deep `-command-` engine offers scripts, aliases, builtins, functions, commands, fuzzy-filtered and capped
  And no files or dirs are offered
  And option offers stop once the command position is reached

Scenario: words after the command complete as the inner command's own
  Status: implemented
  When I complete a word after the command, e.g. `exec-for-all-repos.zsh git chec<TAB>`
  Then the remaining words re-dispatch as their own command line (`checkout` offered)

Scenario: root dir options complete deep dirs
  Status: implemented
  When I complete `-C <TAB>` or `--chpwd=<TAB>`
  Then the deep files engine offers dirs only (`file-types dirs` on the `_deep_files` context)
  And accepting a match keeps the `--chpwd=` prefix on the line (`compadd -i "$IPREFIX"` alongside `-U` in the engine)

Scenario: --include/--exclude complete discovered repos
  Status: implemented
  When I complete `--include=<TAB>` or `--exclude=<TAB>`
  Then discovered repos are offered as root-relative paths, comma-separated appendable
  And the root is taken from `-C`/`--chpwd=` already on the line, default pwd
  And discovery mirrors the script: `.git` entries pruned recursively, the root itself by basename

Scenario: --must-filter completes its filter values
  Status: implemented
  When I complete `--must-filter=<TAB>`
  Then `changes`, `off-main`, `unsynced` are offered comma-separated

Scenario: stock compsys options are restored despite sticky autoload
  Status: implemented
  Given completion functions autoload sticky-emulated (`emulate zsh -LRc`), resetting options like `extendedglob`
  When the completion function or its repo helper runs
  Then it restores `$_comp_options` via `setopt localoptions`, so called compsys functions see standard completion options
<!--[<] 🤖🤖 -->
