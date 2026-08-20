{{- remoteFile (printf "%s?ref=%s" "gitlab.com/konradodwrot/prose//repos/configs/ai/templates-llm/git-branch-name-suggest.tmpl.md" (env.Getenv "PROSE_REF")) -}}
