#!/usr/bin/env zsh
#>[what]
#   Suggest commit message via LLM.
#   Usage: <extra-instructions-on-stdin> | llm-git-commit-msg-suggest
#   stdin: optional extra instructions.
#   provider, model, template, env from /etc/custom/llm.yml.
#   Upstream: git-commit skill. Out: { "subject": ..., "description": ... }.
#/[what]

set -e

source "${0:A:h}/lib/llm-lib.zsh"
read -r llm_script llm_model llm_template <<<"$(lib-llm-config-load "${0:t}")"
lib-llm-env-export "${0:t}"
autoload -Uz fn-log-msg


##[>] script input
typeset -A script_input=(
  in_instructions_runtime "$([[ -t 0 ]] || cat)"
)
##[<] script input


##[>] template input 🤖
get_current_branch() { local b=$(git rev-parse --abbrev-ref HEAD); [[ $b == main ]] || echo $b }
get_commit_template() {
  local f=$(git config --get commit.template); f=${f/#\~/$HOME}
  [[ -n $f && -f $f ]] && cat "$f"
}

typeset -A template_input=(
  CURRENT_BRANCH "$(get_current_branch)"
  COMMIT_TEMPLATE "$(get_commit_template)"
  DIFF_FULL "$(git diff --cached)"
  DIFF_STATS "$(git diff --cached --stat)"
  INSTRUCTIONS_RUNTIME "$script_input[in_instructions_runtime]"
)
##[<] template input 🤖


[[ -n $template_input[DIFF_FULL] ]] || { echo "error: nothing staged" >&2; exit 1 }
fn-log-msg -t "${0:t}" "model $llm_model, branch ${template_input[CURRENT_BRANCH]:-none}, staged diff ${#template_input[DIFF_FULL]} chars"

##[>] fill template 🤖
prompt=$(lib-llm-prompt-fill "$llm_template" template_input)
fn-log-msg -t "${0:t}" "prompt: ${#prompt} chars, calling llm ..."
##[<] fill template 🤖


##[>] llm invocation
schema='{
  "type": "object",
  "properties": {
    "subject": { "type": "string" },
    "description": { "type": "string" }
  },
  "required": ["subject", "description"],
  "additionalProperties": false
}'

out=$(<<< "$prompt" "$llm_script" --model "$llm_model" --schema "$schema")
fn-log-msg -t "${0:t}" "llm returned ${#out} chars"
print -r -- "$out"
##[<] llm invocation
