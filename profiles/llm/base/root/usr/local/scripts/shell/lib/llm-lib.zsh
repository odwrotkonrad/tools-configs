#!/usr/bin/env zsh
#>[what]
#   Sourced lib: resolve an llm-* script's provider from /etc/custom/llm.yml.
#   provider = providers[script.provider.id] merged with script.provider.config.
#   Usage: source ${0:A:h}/lib/llm-lib.zsh
#     read -r llm_script llm_model llm_template <<<"$(lib-llm-config-load <script-name>)"
#     lib-llm-env-export <script-name>
#     prompt=$(lib-llm-prompt-render <template> <assoc-name>)
#/[what]

llm_config_path=/etc/custom/llm.yml

##[>] lib-llm-config-load 🤖🤖
lib-llm-config-load() {
  local name=$1
  name=$name yq '
    .scripts[strenv(name)] as $s
    | (.providers[$s.provider.id] * ($s.provider.config // {})) as $p
    | [$p.script, $p.model, $s.template] | join(" ")
  ' "$llm_config_path"
}
##[<] lib-llm-config-load 🤖🤖

##[>] lib-llm-env-export 🤖🤖
#[what] export provider env <- script env. [why] preset caller env wins, no override
lib-llm-env-export() {
  local name=$1 kv key
  for kv in "${(@f)$(name=$name yq '
    .scripts[strenv(name)] as $s
    | (.providers[$s.provider.id] * ($s.provider.config // {})) as $p
    | (($p.env // {}) * ($s.env // {})) | to_entries | .[] | .key + "=" + .value
  ' "$llm_config_path")}"; do
    key=${kv%%=*}
    [[ -n $kv && ! -v $key ]] && export "$kv"
  done
}
##[<] lib-llm-env-export 🤖🤖

##[>] lib-llm-prompt-render 🤖🤖
lib-llm-prompt-render() {
  local template=$1 assoc=$2
  local templates_dir=/usr/local/scripts/shell/templates-llm
  local -A vars=("${(@kv)${(P)assoc}}")

  for k v in "${(@kv)vars}"; do export "$k"="$v"; done
  che render tpl -f "$templates_dir/$template"
}
##[<] lib-llm-prompt-render 🤖🤖
