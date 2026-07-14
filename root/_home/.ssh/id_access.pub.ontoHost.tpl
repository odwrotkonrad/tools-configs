{{ if getenv "GCP_SA_KEY" }}{{ secret "gcp://main-493613/sandbox-ssh-access-key-pub" }}{{ else }}{{ secret "op://ProgrammaticAccess/ssh_id_sandbox_access/public" }}{{ end }}
