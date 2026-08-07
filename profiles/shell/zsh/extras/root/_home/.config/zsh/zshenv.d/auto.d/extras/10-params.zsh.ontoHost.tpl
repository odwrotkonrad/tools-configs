#[what] op-rendered env exports (all shells)

export GOOGLE_CLOUD_QUOTA_PROJECT={{ if getenv "GOOGLE_APPLICATION_CREDENTIALS" }}konradodwrot-sandbox-auth{{ else }}{{ secret "op://ProgrammaticAccess/gcp_ko/project_main" }}{{ end }}
