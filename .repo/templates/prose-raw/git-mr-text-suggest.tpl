{{- remoteFile (printf "%s?ref=%s" "gitlab.com/konradodwrot/prose//repos/configs/ai/templates-llm/git-mr-text-suggest.tmpl.md" (env.Getenv "PROSE_REF")) -}}
