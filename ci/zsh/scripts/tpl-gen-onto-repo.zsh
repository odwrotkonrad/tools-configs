#!/bin/zsh
#>[what]
#   render *.repo.tpl under templates/ and ci/ to render-to: frontmatter path
#   --local: also render *local* templates (off by default)
#/[what]

emulate -LR zsh
IFS=
setopt errexit pipefail
autoload -Uz fn-log-msg fn-tpl-strip-empty-frontmatter fn-tpl-inline-includes fn-tpl-make-header

##[>] 🤖🤖
zparseopts -D -F -- -local=local || exit 1
configs=${1:-$HOME/projects/configs}
local_glob='*local*'
##[<] 🤖🤖

function render_template {
  local template=$1
  local render_to

  ##[>] 🤖🤖
  #[what] no frontmatter: render next to the template, sans .repo.tpl
  if [[ $(head -1 $template) != '---' ]] {
    render_to=${template%.repo.tpl}
    { fn-tpl-make-header $render_to $template; gomplate -f $template } > $configs/$render_to
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
    | gomplate > $body

  for render_to ( $render_tos ) {
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
