PATH=$PWD/ci/zsh/scripts:$PWD/ci/zsh/scripts/installs:$PATH
MK_DRY_RUN=
MK_DRY_RUN_RENDER_SECRETS=
##[>] 🤖🤖
{{ localFile ".repo/upstream.env" | alwaysUpdate }}
CONFIGS_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CONFIGS_REF" }}
ARTIFACT_REGISTRY={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ARTIFACT_REGISTRY" }}
CHE_PACKAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CHE_PACKAGES_REF" }}
CHE_BACKUP_AUTO_CREATE=
ENABLE_DARWIN_CI={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ENABLE_DARWIN_CI" }}
GITLAB_TOKEN={{ secret "op://ProgrammaticAccess/gitlab/access_token" }}
TAG_TOKEN={{ shell "glab variable get -R konradodwrot/configs REPO_PROTECTED_VAR_BOT_TAG_TOKEN" }}
##[<] 🤖🤖
