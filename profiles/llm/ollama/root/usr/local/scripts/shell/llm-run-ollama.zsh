#!/usr/bin/env zsh
#>[what]
#   Headless ollama /api/chat wrapper for llm-* scripts.
#   Usage: <prompt-on-stdin> | llm-run-ollama --model <model> [--schema <schema>]
#   --schema sets request `format`, constrains output.
#   think, options (temperature, num_ctx, ...) from llm.yml providers.ollama.
#   Host via OLLAMA_HOST (default 127.0.0.1:11434).
#   Upstream: llm-* scripts. In: prompt on stdin, --model, --schema.
#   Out: structured output object.
#/[what]


set -e

##[>] script input
zparseopts -D -E -- -model:=opt_model -schema:=opt_schema
typeset -A script_input=(
  in_prompt "$(<&0)"

  opt_model "${opt_model[2]}"
  opt_schema "${opt_schema[2]}"
)
##[<] script input

host="${OLLAMA_HOST:-127.0.0.1:11434}"
config_path=/etc/custom/llm.yml
think=$(yq -o=json '.providers.ollama.think // false' "$config_path")
ollama_options=$(yq -o=json -I=0 '.providers.ollama.options // {}' "$config_path")

##[>] 🤖🤖
request='{
  "model": $model,
  "stream": false,
  "think": $think,
  "options": $options,
  "messages": [{"role": "user", "content": $content}]
}
+ (if $schema == null then {} else {"format": $schema} end)'

response=$(jq -n \
  --arg model "$script_input[opt_model]" \
  --arg content "$script_input[in_prompt]" \
  --argjson schema "${script_input[opt_schema]:-null}" \
  --argjson think "$think" \
  --argjson options "$ollama_options" \
  "$request" \
  | curl --connect-timeout 30 --retry 10 --retry-delay 30 -s "http://$host/api/chat" -d @-)

content=$(jq -r '.message.content
  | sub("^```(json)?\\n?"; "") | sub("\\n?```$"; "")' <<< "$response")

if jq -e . <<< "$content" >/dev/null 2>&1; then
  jq <<< "$content"
else
  print -r -- "$content"
fi
##[<] 🤖🤖
