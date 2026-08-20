{{- remoteFile (printf "%s?ref=%s" "gitlab.com/konradodwrot/prose//repos/configs/ai/templates-llm/git-commit-msg-suggest.tmpl.md" (env.Getenv "PROSE_REF")) -}}
