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
  settings.json.ontoHost.tpl:
  agents/:
  agent-memory/:
  commands/:
  output-styles/:
    interactive-code.md:
  skills/:
    user-decipher-code/:
      SKILL.md:
      scripts/:
        print-lang-principles.sh:
        resolve-scope.sh:
    user-git-ops/:
      SKILL.md:
    user-humanize-prose/:
      SKILL.md:
      scripts/:
        resolve-scope.sh:
    user-junior-wrote-this-code-refactor-redesign/:
      SKILL.md:
    user-prettify-code/:
      SKILL.md:
      scripts/:
        print-lang-principles.sh:
        resolve-scope.sh:
  themes/:
  rules/:
    code/:
      code.md:
      go/:
        principles.md:
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
        functions.md:
        zsh.md:
    docs/:
      prose.md:
  plugins/:
    installed_plugins.json:
    known_marketplaces.json:
    marketplaces/:
```

Global instructions (`~/.config/claude/CLAUDE.md`) are not in this tree: rendered onto the host from `root/_home/.config/ai-agents/templates/AGENTS.md.ontoHost.tpl` (llm/base profile). It `@`-includes `~/.config/ai-agents/docs/`: `comments.md`, `git.md`, `testing.md`.

Project instructions live in `<repo>/.claude/` (preferred) or `<repo>/CLAUDE.md`.

### Documentation

Local: `$ claude --help`

Online:
- settings.json schema: https://json.schemastore.org/claude-code-settings.json
- docs base: `https://code.claude.com/docs`
- pages index: `/llms.txt` · all-in-one: `/llms-full.txt`
- keywords: settings, permissions, memory, env-vars, cli-reference, claude-directory, commands, sub-agents, skills, output-styles, plugins, plugins-reference, hooks, mcp
