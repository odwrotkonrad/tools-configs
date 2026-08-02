#[what] op-rendered env exports (all shells)

export GOOGLE_CLOUD_QUOTA_PROJECT={{ if getenv "GCP_SA_KEY" }}main-493613{{ else }}{{ secret "op://ProgrammaticAccess/gcp_ko/project_main" }}{{ end }}
