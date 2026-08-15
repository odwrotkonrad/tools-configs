#!/usr/bin/env zsh
#>[what]
#   Headless claude -p wrapper for llm-* scripts.
#   Usage: <prompt-on-stdin> | llm-run-claude-code --model <model> --schema <schema>
#   Sets ANTHROPIC_MODEL from --model.
#   Auth: default claude.ai login (no ANTHROPIC_API_KEY).
#   Upstream: llm-git-* scripts. In: prompt on stdin, --model, --schema.
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

export ANTHROPIC_MODEL="$script_input[opt_model]"

<<< "$script_input[in_prompt]" claude -p \
  --system-prompt '' \
  --output-format json \
  --tools "" \
  --allowedTools "" \
  --effort low \
  --json-schema "$script_input[opt_schema]" | jq '
##[>] 🤖🤖
    def unwrap: if type == "string"
      then ((try fromjson catch null) as $p
        | if ($p | type) == "object" and ($p | keys) == ["value"] then $p.value else . end)
      else . end;
    .structured_output | if type == "object" then map_values(unwrap) else . end
##[<] 🤖🤖
  '
