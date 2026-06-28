#!/usr/bin/env zsh
#>[what]
#   LLM driven change request (MR/PR) generation
#   Usage: <extra-instructions-on-stdin> | llm-git-mr-text-suggest [--range <range>]
#   extra-instructions: optional, from stdin when piped.
#   provider, model, template, env resolved from /etc/custom/llm.yml.
#   Upstream: git-mr skill. Downstream: net diff, commits as secondary context.
#   Out: { "title": ..., "description": ... }.
#/[what]

set -e

source "${0:A:h}/lib/llm-lib.zsh"
read -r llm_script llm_model llm_template <<<"$(lib-llm-config-load "${0:t}")"
lib-llm-env-export "${0:t}"


##[>] script input
zparseopts -D -E -- -range:=opt_range
typeset -A script_input=(
  in_instructions_runtime "$([[ -t 0 ]] || cat)"

  opt_range "${opt_range[2]:-main..HEAD}"
)
##[<] script input


##[>] template input 🤖
typeset -A template_input=(
  LATEST_COMMIT "$(git log -1 --format='%B' HEAD)"
  DIFF_FULL "$(git diff "${script_input[opt_range]/../...}")"
  DIFF_STATS "$(git diff --stat "${script_input[opt_range]/../...}")"
  INSTRUCTIONS_RUNTIME "$script_input[in_instructions_runtime]"
)
##[<] template input 🤖

# no commits: error
[[ -n "$(git log --format=%h "$script_input[opt_range]")" ]] || { echo "error: no commits in $script_input[opt_range]" >&2; exit 1 }


##[>] fill template 🤖
prompt=$(lib-llm-prompt-fill "$llm_template" template_input)
##[<] fill template 🤖


##[>] llm invocation
schema='{
  "type": "object",
  "properties": {
    "title": { "type": "string" },
    "description": { "type": "string" }
  },
  "required": ["title", "description"],
  "additionalProperties": false
}'

<<< "$prompt" "$llm_script" --model "$llm_model" --schema "$schema"
##[<] llm invocation
