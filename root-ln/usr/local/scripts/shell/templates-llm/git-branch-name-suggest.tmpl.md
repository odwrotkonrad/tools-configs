## Data

### Full Diff
{{ getenv "DIFF_FULL" }}

### Diff Stats
{{ getenv "DIFF_STATS" }}
{{ with getenv "LATEST_COMMIT" }}
### Latest Commit (intent context, the branch holds related work)
{{ . }}
{{ end }}{{ if getenv "CURRENT_BRANCH" }}
### Current Branch (keep it if it already fits the changes ~80%, only rename if clearly inaccurate)
{{ getenv "CURRENT_BRANCH" }}
{{ end }}{{ with getenv "COMMIT_TEMPLATE" }}
### Commit Template (the type/scope vocabulary to draw from)
{{ . }}
{{ end }}
## Style

{{ readMarkdown "--strip-frontmatter" "--strip-comments" "--increment-heading-levels" "/Users/ko/.config/claude/rules/docs/prose.md" | strings.TrimSpace }}

## Task

Suggest a branch name from the in-flight changes (staged + unstaged) and the
latest commit. Fill `name`. Terse, specific.

- keep the current branch if it already fits the changes (~80%), only suggest a new name when it is clearly inaccurate or a `tmp/...` scratch name
- prefer the latest commit, fall back to the staged/unstaged change summaries when there is no commit
- nothing to derive a type/scope from (no commit, no staged, no unstaged) → `tmp/scratch-<datetime>`
- read `type(scope)` from the latest commit subject, else infer from the changed paths
- one scope: `<type>/<scope>-<desc>`, `<desc>` = 2-4 hyphenated words
- many scopes: `<type>/<scope>-<scope>-...`, order by amount of changes (most first), no desc
- lowercase, hyphenated, no spaces

## Examples

- one: `config/zsh-multiline-buffer`
- many: `config/zsh-direnv-claude-vscode`

{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}
