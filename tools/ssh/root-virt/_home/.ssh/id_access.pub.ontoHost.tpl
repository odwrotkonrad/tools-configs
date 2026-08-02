{{ if getenv "GOOGLE_APPLICATION_CREDENTIALS" }}{{ secret "gcp://main-493613/sandbox-ssh-access-key-pub" }}{{ else }}{{ secret "op://ProgrammaticAccess/ssh_id_sandbox_access/public" }}{{ end }}
