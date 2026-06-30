#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Split leading --- YAML frontmatter from body, emit YAML doc:
#   `frontmatter:` (header verbatim), `body:` (literal block scalar).
#   Usage: render-with-frontmatter <file>
#   Upstream: gomplate `renderWithFrontmatter` plugin. Downstream: <file>.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
setopt err_return

file=$1
content=$(<"$file")

front=$(print -r -- "$content" | sed -n '1{/^---$/!q;};1d;/^---$/q;p')
body=$(print -r -- "$content" | sed '1{/^---$/!q;};1,/^---$/d')

print -r -- "frontmatter:"
print -r -- "$front" | sed 's/^/  /'
print -r -- "body: |"
print -r -- "$body" | sed 's/^/  /'
##[<] 🤖🤖
