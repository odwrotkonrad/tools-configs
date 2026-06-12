## Data
{{ if getenv "CURRENT_BRANCH" }}
### Current Branch (keep it if it already fits the changes ~80%, only rename if clearly inaccurate)
{{ getenv "CURRENT_BRANCH" }}
{{ end }}
### Full Diff
{{ getenv "CHANGES" }}
{{ with getenv "COMMIT_TEMPLATE" }}
### Commit Template (the type/scope vocabulary to draw from)
{{ . }}
{{ end }}
### Commit List
{{ getenv "COMMITS_LOG_SHORT" }}

### Diff Stats
{{ getenv "CHANGES_STATS" }}

## Style

{{ stripmd "--strip-frontmatter" "--strip-comments" "--increment-heading-levels" "/Users/ko/.config/claude/rules/docs/prose.md" | strings.TrimSpace }}

## Task

Suggest a branch name from the commit subjects and the in-flight changes
(staged + unstaged). Fill `name`. Terse, specific.

- keep the current branch if it already fits the changes (~80%), only suggest a new name when it is clearly inaccurate or a `tmp/...` scratch name
- prefer commit subjects, fall back to the staged/unstaged change summaries when there are few or no commits
- nothing to derive a type/scope from (no commits, no staged, no unstaged) → `tmp/scratch-<datetime>`
- read `type(scope)` from each subject, `<type>` = first commit's type, else infer from the changed paths
- one scope: `<type>/<scope>-<desc>`, `<desc>` = 2-4 hyphenated words
- many scopes: `<type>/<scope>-<scope>-...`, order by amount of changes (most first), no desc
- lowercase, hyphenated, no spaces

## Examples

- one: `config/zsh-multiline-buffer`
- many: `config/zsh-direnv-claude-vscode`

{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}
