---
paths:
  - "**/claude/settings.json"
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
  - "**/.zclaude"
  - "**/.claude.json"
  - "**/Application Support/ClaudeCode/**"
---

## Claude Code Config

### Files

```yml
root/Users/ko/.config/claude/:
  CLAUDE.md: # global instructions, all projects
  settings.json:
  agents/:
  agent-memory/:
  commands/:
  output-styles/:
  skills/:
  themes/:
  rules/:
    config/:
      claudecode.md: # this file
      git.md:
      vscode.md:
      zsh/:
        zsh.md:
        functions.md:
  plugins/:
    installed_plugins.json:
    known_marketplaces.json:
    marketplaces/:
```

Project-scoped instructions lives in (preferred) `<repo>/.claude/` or `<repo>/CLAUDE.md`.

### Documentation

#### Local
- `$ claude --help`

#### Online

settings.json schema:  https://json.schemastore.org/claude-code-settings.json

Claude Code Documentation Online
- base URL: `https://code.claude.com/docs`
- md pages index: /llms.txt
- md all in one .md doc: /llms-full.txt
- keywords: **settings**, **permissions**, **memory**, **env-vars**, cli-reference, claude-directory, commands, sub-agents, skills, output-styles, plugins, plugins-reference, hooks, mcp
