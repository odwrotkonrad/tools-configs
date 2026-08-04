{{ if getenv "GOOGLE_APPLICATION_CREDENTIALS" }}{{ secret "gcp://main-493613/sandbox-ssh-signing-key-pub" }}{{ else }}{{ secret "op://ProgrammaticAccess/ssh_id_sandbox_signing/public" }}{{ end }}
