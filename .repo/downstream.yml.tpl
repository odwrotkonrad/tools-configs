##[>] 🤖
downstream:
  - uri: gitlab.com/konradodwrot/tools-configs
    type: gitRepository
    versionEnvVar: TOOLS_CONFIGS_REF
    version: {{ env.Getenv "TOOLS_CONFIGS_REF" }}
##[<] 🤖
