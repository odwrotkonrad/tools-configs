##[>] 🤖🤖
concurrent = 2
listen_address = "localhost:9252"

[[runners]]
  name = "ko-mac-tart"
  url = "https://gitlab.com"
  token = "{{ secret "op://ProgrammaticAccess/gitlab_runner/token" }}"
  executor = "custom"
  environment = ["TART_EXECUTOR_SSH_USERNAME=user", "TART_EXECUTOR_SSH_PASSWORD={{ secret "op://ProgrammaticAccess/gitlab_runner/vm_password" }}"]
  [runners.custom_build_dir]
    enabled = true
  [runners.feature_flags]
    FF_RESOLVE_FULL_TLS_CHAIN = false
  [runners.custom]
    config_exec = "gitlab-tart-executor"
    config_args = ["config", "--guest-builds-dir", "/Users/user/projects"]
    prepare_exec = "gitlab-tart-executor"
    prepare_args = ["prepare", "--memory", "4096", "--cpu", "4"]
    run_exec = "gitlab-tart-executor"
    run_args = ["run"]
    cleanup_exec = "gitlab-tart-executor"
    cleanup_args = ["cleanup"]
##[<] 🤖🤖
