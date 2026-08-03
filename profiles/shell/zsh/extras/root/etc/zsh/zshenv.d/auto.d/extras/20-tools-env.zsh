##[>] 🤖🤖
setopt allexport

AWS_DEFAULT_OUTPUT='json'
CLOUDSDK_CORE_DEFAULT_FORMAT='json'
AZURE_CORE_OUTPUT='json'
CODEX_HOME="${XDG_CONFIG_HOME}/codex"
CODEX_SQLITE_HOME="${XDG_STATE_HOME}/codex"
RUST_LOG="info"
PKG_CONFIG_PATH='/opt/homebrew/opt/ruby/lib/pkgconfig'
PIP_DISABLE_PIP_VERSION_CHECK='1'
RIPGREP_CONFIG_PATH='/etc/rg/rgrc'
SSH_ASKPASS='/usr/local/scripts/shell/ssh-askpass-op.bash'
SSH_ASKPASS_REQUIRE='force'

unsetopt allexport
##[<] 🤖🤖
