##[>] 🤖
produces:
  - uri: gitlab.com/konradodwrot/configs
    type: gitRepository
    versionEnvVar: CONFIGS_REF
    version: {{ env.Getenv "CONFIGS_REF" }}
##[<] 🤖
