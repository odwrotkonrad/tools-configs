---
render-to: .env
---
{{ mergeUpsertEnv ".env" "templates/1-env/local.env.example" -}}
