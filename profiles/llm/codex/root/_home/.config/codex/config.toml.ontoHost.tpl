#:schema https://developers.openai.com/codex/config-schema.json

project_root_markers = [".git"]
oss_provider = "ollama"
model_provider = "openai"
model_reasoning_summary = "concise"
model_reasoning_effort = "medium"
plan_mode_reasoning_effort = "medium"
web_search = "cached"
model_verbosity = "low"
model_supports_reasoning_summaries = true
hide_agent_reasoning = true
show_raw_agent_reasoning = false
file_opener = "vscode"
disable_paste_burst = false
check_for_update_on_startup = true
allow_login_shell = true
log_dir = "{{ env.Getenv "HOME" }}/.local/state/codex/log"
sqlite_home = "{{ env.Getenv "HOME" }}/.local/state/codex"

[projects."{{ env.Getenv "PWD" }}"]
trust_level = "trusted"

[projects."{{ env.Getenv "HOME" }}/.config/codex"]
trust_level = "trusted"

[projects."{{ env.Getenv "HOME" }}/.codex"]
trust_level = "trusted"

[tui]
status_line = ["context-used", "model-with-reasoning", "thread-id"]
status_line_use_colors = true
raw_output_mode = true
notifications = false

[tui.model_availability_nux]
"gpt-5.5" = 4

[otel]
environment = "local"
exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
metrics_exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
trace_exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
log_user_prompt = true

[analytics]
enabled = true

[feedback]
enabled = true

[memories]
disable_on_external_context = false
generate_memories = true
max_raw_memories_for_consolidation = 256
max_rollout_age_days = 90
max_unused_days = 90
use_memories = true

[history]
persistence = "save-all"
max_bytes = 104857600

[agents]
max_threads = 6

[tools]
web_search = { context_size = "low" }

[features]
codex_git_commit = false
memories = true
shell_tool = true
shell_snapshot = true
undo = true
##[<] 🤖🤖
