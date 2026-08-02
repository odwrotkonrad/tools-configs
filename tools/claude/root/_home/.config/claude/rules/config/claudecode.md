---
paths:
  - "**/claude/settings.json"
  - "**/claude/settings.json.ontoHost.tpl"
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
  - "**/.zclaude"
  - "**/.claude.json"
  - "**/Application Support/ClaudeCode/**"
---

## Claude Code Config

### Files

```yml
root/_home/.config/claude/:
  CLAUDE.md:                # global instructions, all projects
  comments.md:              # @-included by CLAUDE.md
  git.md:                   # @-included by CLAUDE.md
  settings.json.ontoHost.tpl:
  agents/:
  agent-memory/:
  commands/:
  output-styles/:
    interactive-code.md:
  skills/:
    user-git-branch-name-upsert/:
    user-git-commit/:
    user-git-mr-upsert/:
    user-git-upsert-all/:
  themes/:
  rules/:
    code/:
      code.md:
      python/:
        python.md:
        scripts.md:
      zsh/:
        zsh.md:
    config/:
      claudecode.md:        # this file
      git.md:
      ssh.md:
      vscode.md:
      zsh/:
        zsh.md:
        functions.md:
    docs/:
      prose.md:
  plugins/:
    installed_plugins.json:
    known_marketplaces.json:
    marketplaces/:
```

Project instructions live in `<repo>/.claude/` (preferred) or `<repo>/CLAUDE.md`.

### Documentation

Local: `$ claude --help`

Online:
- settings.json schema: https://json.schemastore.org/claude-code-settings.json
- docs base: `https://code.claude.com/docs`
- pages index: `/llms.txt` · all-in-one: `/llms-full.txt`
- keywords: settings, permissions, memory, env-vars, cli-reference, claude-directory, commands, sub-agents, skills, output-styles, plugins, plugins-reference, hooks, mcp
