#!/usr/bin/env zsh
#>[what]
#   LLM driven branch name generation
#   Usage: <extra-instructions-on-stdin> | llm-git-branch-name-suggest [--range <range>]
#   extra-instructions: optional, read from stdin when piped.
#   provider, model, template, env resolved from /etc/custom/llm.yml.
#   Upstream: git-branch-name-upsert. Downstream: llm run script from llm.yml.
#   Out: { "name": ... }.
#   Exit Codes: 1 no commits in range
#/[what]

set -e

source "${0:A:h}/lib/llm-lib.zsh"
read -r llm_script llm_model llm_template <<<"$(lib-llm-config-load "${0:t}")"
lib-llm-env-export "${0:t}"
autoload -Uz fn-log-msg


##[>] script input
zparseopts -D -E -- -range:=opt_range
typeset -A script_input=(
  in_instructions_runtime "$([[ -t 0 ]] || cat)"

  opt_range "${opt_range[2]:-$(if [[ $(git rev-parse --abbrev-ref HEAD) == main ]] { print origin/main..HEAD } else { print main..HEAD })}"
)
##[<] script input


##[>] template vars 🤖
get_current_branch() { local b=$(git rev-parse --abbrev-ref HEAD); [[ $b == main ]] || echo $b }
get_recent_commits() { git log --format='%B' --reverse $script_input[opt_range] }
get_commit_template() {
  local f=$(git config --get commit.template); f=${f/#\~/$HOME}
  [[ -n $f && -f $f ]] && cat "$f"
}

typeset -A template_vars=(
  CURRENT_BRANCH "$(get_current_branch)"
  COMMIT_TEMPLATE "$(get_commit_template)"
  RECENT_COMMITS "$(get_recent_commits)"
  INSTRUCTIONS_RUNTIME "$script_input[in_instructions_runtime]"
)
##[<] template vars 🤖

##[>] 🤖🤖
if [[ -z $template_vars[RECENT_COMMITS] ]] {
  fn-log-msg -t "${0:t}" "no commits in $script_input[opt_range], nothing to name" >&2
  exit 1
}
##[<] 🤖🤖
fn-log-msg -t "${0:t}" "range $script_input[opt_range], model $llm_model, current branch ${template_vars[CURRENT_BRANCH]:-none}" >&2


##[>] render prompt 🤖
prompt=$(lib-llm-prompt-render "$llm_template" template_vars)
fn-log-msg -t "${0:t}" "prompt: ${#prompt} chars, calling llm ..." >&2
##[<] render prompt 🤖


##[>] llm invocation
schema='{
  "type": "object",
  "properties": {
    "name": { "type": "string" }
  },
  "required": ["name"],
  "additionalProperties": false
}'

out=$(<<< "$prompt" "$llm_script" --model "$llm_model" --schema "$schema")
fn-log-msg -t "${0:t}" "llm returned ${#out} chars" >&2
print -r -- "$out"
##[<] llm invocation
