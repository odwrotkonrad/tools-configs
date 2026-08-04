{{ if getenv "GOOGLE_APPLICATION_CREDENTIALS" }}{{ secret "gcp://main-493613/sandbox-ssh-private-key" }}{{ else }}{{ secret "op://ProgrammaticAccess/ssh_id_sandbox_access/private" }}{{ end }}
