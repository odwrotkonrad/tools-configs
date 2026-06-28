#!/usr/bin/env zsh
#>[what]
#   Headless ollama /api/chat wrapper for llm-* scripts.
#   Usage: <prompt-on-stdin> | llm-run-ollama --model <model> [--schema <schema>]
#   Schema, when given, is set as the request `format` to constrain output.
#   think and options (temperature, num_ctx, ...) read from llm.yml providers.ollama.
#   Host overridable via OLLAMA_HOST (default 127.0.0.1:11434).
#   Upstream: llm-* scripts. Downstream: prompt on stdin, --model, --schema.
#   Out: the structured output object.
#/[what]


set -e

##[>] script input
zparseopts -D -E -- -model:=opt_model -schema:=opt_schema
typeset -A script_input=(
  in_instructions "$(<&0)"

  opt_model "${opt_model[2]}"
  opt_schema "${opt_schema[2]}"
)
##[<] script input

host="${OLLAMA_HOST:-127.0.0.1:11434}"
config=/etc/custom/llm.yml
think=$(yq -o=json '.providers.ollama.think // false' "$config")
ollama_options=$(yq -o=json -I=0 '.providers.ollama.options // {}' "$config")

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
  --arg content "$script_input[in_instructions]" \
  --argjson schema "${script_input[opt_schema]:-null}" \
  --argjson think "$think" \
  --argjson options "$ollama_options" \
  "$request" \
  | curl -s "http://$host/api/chat" -d @-)

content=$(jq -r '.message.content
  | sub("^```(json)?\\n?"; "") | sub("\\n?```$"; "")' <<< "$response")

#[what] pretty-print json when valid, else emit raw model output
if jq -e . <<< "$content" >/dev/null 2>&1; then
  jq <<< "$content"
else
  print -r -- "$content"
fi
##[<] 🤖🤖
