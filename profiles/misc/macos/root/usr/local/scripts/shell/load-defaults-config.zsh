#!/bin/zsh

set -o pipefail

yq=/opt/homebrew/bin/yq

yaml=$(</dev/stdin)  #[where] /etc/defaults.yml


while IFS=$'\t' read -r domain key tag value; do
  case $tag in
    '!!str')   defaults write  "$domain" "$key" -string "$value" ;;
    '!!bool')  defaults write  "$domain" "$key" -bool   "$value" ;;
    '!!int')   defaults write  "$domain" "$key" -int    "$value" ;;
    '!!float') defaults write  "$domain" "$key" -float  "$value" ;;
    '!!null')  defaults delete "$domain" "$key" || true ;;
  esac
done < <($yq -r '
  .domains | to_entries[] | .key as $d | .value | to_entries[] |
  [$d, .key, (.value | tag), (.value | tostring)] | @tsv
' <<<"$yaml")

##[>] 🤖🤖
$yq -r '.apps[]' <<<"$yaml" | xargs -n1 killall || true
##[<] 🤖🤖
