{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "cleanupPeriodDays": 90,
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_TRACES_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317",
    "OTEL_METRIC_EXPORT_INTERVAL": "10000",
    "OTEL_LOGS_EXPORT_INTERVAL": "5000",
    "OTEL_TRACES_EXPORT_INTERVAL": "5000",
    "OTEL_LOG_TOOL_DETAILS": "1",
    "OTEL_LOG_TOOL_CONTENT": "1",
    "OTEL_LOG_RAW_API_BODIES": "1",
    "OTEL_LOG_USER_PROMPTS": "1",
    "OTEL_METRICS_INCLUDE_VERSION": "1",
    "OTEL_METRICS_INCLUDE_ENTRYPOINT": "1",
    "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA": "1",
    "CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS": "1",
    "CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS": "1",
    "CLAUDE_CODE_DISABLE_1M_CONTEXT": "0",
    "DISABLE_PROMPT_CACHING": "0",
    "CLAUDE_CODE_DISABLE_BACKGROUND_TASKS": "0"
  },
  "attribution": {
    "commit": "Signed-off-by: konradodwrot odwrotkonrad@gmail.com",
    "pr": ""
  },
  "permissions": {
    "allow": [
      "Bash(awk *)",
      "Bash(cd ./*)",
      "Bash(che *)",
      "Bash(che)",
      "Bash(curl -fsSL https://api.github.com/*)",
      "Bash(curl -fsSL https://github.com/*)",
      "Bash(curl -fsSL https://gitlab.com/*)",
      "Bash(curl -sfI *)",
      "Bash(echo *)",
      "Bash(git add *)",
      "Bash(git check-ignore *)",
      "Bash(git checkout *)",
      "Bash(git commit *)",
      "Bash(git diff *)",
      "Bash(git fetch *)",
      "Bash(git log *)",
      "Bash(git ls-remote *)",
      "Bash(git ls-tree *)",
      "Bash(git mv *)",
      "Bash(git pull *)",
      "Bash(git push *)",
      "Bash(git remote *)",
      "Bash(git restore *)",
      "Bash(git rev-list *)",
      "Bash(git show *)",
      "Bash(git status *)",
      "Bash(git switch *)",
      "Bash(git tag *)",
      "Bash(git-branch-name-upsert.zsh)",
      "Bash(git-commit-upsert.zsh *)",
      "Bash(git-mr-upsert.zsh)",
      "Bash(git-upsert-all.zsh *)",
      "Bash(glab auth *)",
      "Bash(glab ci *)",
      "Bash(glab mr *)",
      "Bash(go build *)",
      "Bash(go env *)",
      "Bash(go get *)",
      "Bash(go mod *)",
      "Bash(go run *)",
      "Bash(go test *)",
      "Bash(go version *)",
      "Bash(go vet *)",
      "Bash(gofmt *)",
      "Bash(grep *)",
      "Bash(lefthook *)",
      "Bash(make *)",
      "Bash(make)",
      "Bash(man *)",
      "Bash(mkdir -p *)",
      "Bash(rg *)",
      "Bash(tail *)",
      "Bash(tar -tzf *)",
      "Bash(terraform init *)",
      "Bash(terraform validate *)",
      "Bash(terraform version *)",
      "Bash(zsh -n *)",
      "Bash(llm-git-branch-name-suggest.zsh *)",
      "Bash(llm-git-branch-name-suggest.zsh)",
      "Bash(llm-git-commit-msg-suggest.zsh *)",
      "Bash(llm-git-commit-msg-suggest.zsh)",
      "Bash(llm-git-mr-text-suggest.zsh *)",
      "Bash(llm-git-mr-text-suggest.zsh)",
      "Bash(* --help)",
      "Bash(* -h)",
      "Edit(**/*)",
      "Edit(//tmp/**)",
      "Edit(//private/tmp/**)",
      "ExitPlanMode",
      "LSP",
      "Read(**/*)",
      "Read(//tmp/**)",
      "Read(//private/tmp/**)",
      "Read(//Applications/Visual Studio Code.app/Contents/Resources/app/extensions/**)",
      "Read(/{{ env.Getenv "HOME" }}/.local/state/git-wrappers/**)",
      "Read(/{{ env.Getenv "HOME" }}/go/pkg/mod/**)",
      "Read(/{{ env.Getenv "HOME" }}/projects/gitlab/**)",
      "WebFetch(domain:docs.gitlab.com)",
      "WebFetch(domain:docs.gomplate.ca)",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:goreleaser.com)",
      "WebFetch(domain:raw.githubusercontent.com)",
      "WebFetch(domain:registry.terraform.io)",
      "WebSearch"
    ],
    "deny": [
      "Agent(claude-code-guide)",
      "Agent(Explore)",
      "Bash(git stash)",
      "Bash(git stash *)",
      "Grep",
      "Agent(general-purpose)",
      "Agent(Plan)",
      "Agent(statusline-setup)",
      "mcp__computer",
      "Monitor",
      "NotebookEdit",
      "PowerShell",
      "TaskCreate",
      "TaskGet",
      "TaskList",
      "TaskOutput",
      "TaskStop",
      "TaskUpdate",
      "TodoWrite"
    ],
    "ask": [
      "Skill(user-git-branch-name-upsert)",
      "WebFetch",
      "Skill(user-git-commit)",
      "Skill(user-git-mr-upsert)",
      "Skill(user-git-upsert-all)"
    ],
    "defaultMode": "{{ if eq (env.Getenv "CHE_IS_VIRT") "true" }}bypassPermissions{{ else }}default{{ end }}"
  },
  "model": "claude-fable-5[1m]",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "{ [ -n \"$TMUX_PANE\" ] && tmux set-option -p -t \"$TMUX_PANE\" @claude_attention yes; } 2>/dev/null; true",
            "async": true
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "{ [ -n \"$TMUX_PANE\" ] && tmux set-option -p -t \"$TMUX_PANE\" @claude_attention yes; } 2>/dev/null; true",
            "async": true
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "{ [ -n \"$TMUX_PANE\" ] && tmux set-option -p -u -t \"$TMUX_PANE\" @claude_attention; } 2>/dev/null; true",
            "async": true
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "ccstatusline",
    "padding": 0,
    "refreshInterval": 10
  },
  "enabledPlugins": {
    "gopls-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "ruby-lsp@claude-plugins-official": true,
    "clangd-lsp@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "git",
        "url": "git@github.com:anthropics/claude-plugins-official.git"
      }
    }
  },
  "outputStyle": "Interactive Code",
  "preferredNotifChannel": "terminal_bell",
  "alwaysThinkingEnabled": false,
  "effortLevel": "medium",
  "showClearContextOnPlanAccept": true,
  "autoMemoryEnabled": true,
  "skipWorkflowUsageWarning": true,
  "disableAutoMode": "disable",
  "theme": "auto"
}
