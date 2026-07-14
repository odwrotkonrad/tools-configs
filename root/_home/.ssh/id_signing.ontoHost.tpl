{{ if getenv "GCP_SA_KEY" }}{{ secret "gcp://main-493613/sandbox-ssh-signing-key" }}{{ else }}{{ secret "op://ProgrammaticAccess/ssh_id_sandbox_signing/private" }}{{ end }}
