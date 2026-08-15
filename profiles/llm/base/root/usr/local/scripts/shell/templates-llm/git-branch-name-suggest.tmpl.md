## Style

{{ renderMarkdown "~/.config/claude/rules/docs/prose.md" "remove-frontmatter" "strip-comments" "normalize-headings" }}

## Task

Suggest a branch name from the branch's recent commit messages. Fill `name`.
Terse, specific.

- keep the current branch if it already fits the commits (~80%), only suggest a new name when it is clearly inaccurate or a `tmp/...` scratch name
- infer name from the commit messages, no commits → `tmp/scratch-<datetime>`
- read `type(scope)` from the commit subjects
- one scope: `<type>/<scope>-<desc>`, `<desc>` = 2-4 hyphenated words
- many scopes: `<type>/<scope>-<scope>-...`, order by amount of changes (most first), no desc
- lowercase, hyphenated, no spaces

## Examples

- one: `config/zsh-multiline-buffer`
- many: `config/zsh-direnv-claude-vscode`

## Data
{{ with getenv "COMMIT_TEMPLATE" }}
### Commit Template (the type/scope vocabulary to draw from)
{{ . }}{{ end }}
{{ with getenv "RECENT_COMMITS" }}
### Recent Commits (the branch's commit messages, subject + body)
{{ . }}
{{ end }}{{ if getenv "CURRENT_BRANCH" }}
### Current Branch (keep it if it already fits the changes ~80%, only rename if clearly inaccurate)
{{ getenv "CURRENT_BRANCH" }}
{{ end }}{{ with getenv "INSTRUCTIONS_RUNTIME" }}
## Important

{{ . }}{{ end }}
