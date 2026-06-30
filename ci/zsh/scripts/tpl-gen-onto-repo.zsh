#!/bin/zsh
#>[what]
#   render *.repo.tpl under templates/ and ci/ to render-to: frontmatter path
#   --local: also render *local* templates (off by default)
#   MK_RENDER_SKIP: comma-separated render-to dests to omit (e.g. .env)
#/[what]

emulate -LR zsh
IFS=
setopt errexit pipefail
autoload -Uz fn-log-msg fn-tpl-strip-empty-frontmatter fn-tpl-inline-includes fn-tpl-make-header

##[>] 🤖🤖
zparseopts -D -F -- -local=local || exit 1
configs=${1:-$HOME/projects/configs}
local_glob='*local*'

#[what] MK_RENDER_SKIP: comma-separated render-to dests to omit
local -a skip_dests=( ${(s:,:)MK_RENDER_SKIP} )

#[what] in CI (no 1Password): stub the op plugin so op:// refs render to a placeholder
local -a gomplate_opts=()
if (( ${+CI} )) gomplate_opts=( --plugin op=op-stub.zsh )
##[<] 🤖🤖

function render_template {
  local template=$1
  local render_to

  ##[>] 🤖🤖
  #[what] no frontmatter: render next to the template, sans .repo.tpl
  if [[ $(head -1 $template) != '---' ]] {
    render_to=${template%.repo.tpl}
    if (( $skip_dests[(I)$render_to] )) { fn-log-msg -t skip -- $render_to; return }
    { fn-tpl-make-header $render_to $template; gomplate $gomplate_opts -f $template } > $configs/$render_to
    chmod 0660 $configs/$render_to
    fn-log-msg -t gomplate -- $configs/$render_to
    return
  }

  #[what] render-to as list (scalar back-compat via flatten)
  local -a render_tos=( ${(f)"$(yq -f extract '[.render-to] | flatten | .[]' $template)"} )

  #[what] render body once, fan out per output
  local body=$(mktemp)
  yq -f process 'del(.render-to)' $template \
    | fn-tpl-strip-empty-frontmatter \
    | gomplate $gomplate_opts > $body

  for render_to ( $render_tos ) {
    if (( $skip_dests[(I)$render_to] )) { fn-log-msg -t skip -- $render_to; continue }
    #[what] AGENTS inlines @-includes, CLAUDE keeps links
    fn-tpl-make-header $render_to $template > $configs/$render_to
    if [[ ${render_to:t} == *AGENTS* ]] {
      fn-tpl-inline-includes $configs < $body >> $configs/$render_to
    } else {
      cat $body >> $configs/$render_to
    }
    chmod 0660 $configs/$render_to
    fn-log-msg -t gomplate -- $configs/$render_to
  }
  rm -f $body
  ##[<] 🤖🤖
}

pushd $configs
#[what] . - regular files, D - GLOB_DOT opt (search hidden)
for template ( {templates,ci}/**/*.repo.tpl(.D) ) {
  #[what] skip local templates unless --local 🤖🤖
  if (( ! $#local )) && [[ ${template:t} == ${~local_glob} ]] continue
  render_template $template
}
popd
