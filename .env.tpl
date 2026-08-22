PATH=$PWD/ci/zsh/scripts:$PWD/ci/zsh/scripts/installs:$PATH
MK_DRY_RUN=
MK_DRY_RUN_RENDER_SECRETS=
##[>] 🤖🤖
PROSE_ASSETS_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_PROSE_ASSETS_REF" }}
PROSE_SPEC_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_PROSE_SPEC_REF" }}
MISC_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_MISC_REF" }}
AUTOMATION_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_AUTOMATION_REF" }}
ARTIFACT_REGISTRY={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ARTIFACT_REGISTRY" }}
CI_IMAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CI_IMAGES_REF" }}
CHE_PACKAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CHE_PACKAGES_REF" }}
CHE_BACKUP_AUTO_CREATE=
ENABLE_DARWIN_CI={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ENABLE_DARWIN_CI" }}
GITLAB_TOKEN={{ secret "op://ProgrammaticAccess/gitlab/access_token" }}
TAG_TOKEN={{ shell "glab variable get -R konradodwrot/configs REPO_VAR_TAG_TOKEN" }}
##[<] 🤖🤖
