<!--[>] 🤖🤖 -->
Feature: Runtime gitlab/github auth resolution

Scenario: any shell resolves the gitlab token from the right backend without consumer changes
  Status: todo
  Given `GITLAB_TOKEN_SECRET_PATH` is toggled by `fn-is-virt`
  When a virt shell (sandbox pod, macos-vm) needs the token
  Then it resolves `gcp://konradodwrot-sandbox-auth/sandbox-gitlab-group-token` via the injected ADC
  And a host shell resolves `op://ProgrammaticAccess/gitlab/access_token` via op
  And every consumer (fn-auth-glab, render-tpl) stays context-agnostic

Scenario: a sandbox reaches github read-only with no credential to leak
  Status: todo
  Given no github token is provisioned for the sandbox
  When github operations (clone, api reads) run in the pod
  Then they run unauthenticated
  And `gh api /rate_limit` reports an anonymous rate limit
<!--[<] 🤖🤖 -->
