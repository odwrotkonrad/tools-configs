#!/usr/bin/env zsh
#>[what]
#   LLM driven branch name generation
#   Usage: <extra-instructions-on-stdin> | llm-git-branch-name-suggest [--range <range>]
#   extra-instructions: optional, read from stdin when piped.
#   provider, model, template, env resolved from /etc/custom/llm.yml.
#   Upstream: git-commit, git-mr skills. Downstream: git commit messages.
#   Out: { "name": ... }.
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
get_current_branch() { local b=$(git rev-parse --abbrev-ref HEAD); [[ $b == main ]] || echo $b }
get_recent_commits() { [[ $(git rev-parse --abbrev-ref HEAD) == main ]] || git log --format='%B' --reverse $script_input[opt_range] }
get_commit_template() {
  local f=$(git config --get commit.template); f=${f/#\~/$HOME}
  [[ -n $f && -f $f ]] && cat "$f"
}

typeset -A template_input=(
  CURRENT_BRANCH "$(get_current_branch)"
  COMMIT_TEMPLATE "$(get_commit_template)"
  RECENT_COMMITS "$(get_recent_commits)"
  INSTRUCTIONS_RUNTIME "$script_input[in_instructions_runtime]"
)
##[<] template input 🤖

#[what] no commits, skip llm
if [[ -z $template_input[RECENT_COMMITS] ]]; then
  jq -nc --arg n "tmp/scratch-$(date +%Y%m%d-%H%M%S)" '{name:$n}'
  exit 0
fi


##[>] fill template 🤖
prompt=$(lib-llm-prompt-fill "$llm_template" template_input)
##[<] fill template 🤖


##[>] llm invocation
schema='{
  "type": "object",
  "properties": {
    "name": { "type": "string" }
  },
  "required": ["name"],
  "additionalProperties": false
}'

<<< "$prompt" "$llm_script" --model "$llm_model" --schema "$schema"
##[<] llm invocation
