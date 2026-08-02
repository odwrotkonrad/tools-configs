##[>] 🤖🤖
setopt allexport

ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/.asdfrc"
ASDF_DATA_DIR="${XDG_STATE_HOME}/asdf"
AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
AZURE_CONFIG_DIR="${XDG_CONFIG_HOME}/azure"
GOPATH="${HOME}/go"
PYENV_ROOT="${HOME}/.pyenv"
PYTHONPATH="/usr/local/scripts/python"

unsetopt allexport

typeset -a tool_bins=(
    ${GOPATH}/bin
    ${PYENV_ROOT}/bin
    ${PYENV_ROOT}/shims
    ${ASDF_DATA_DIR}/shims
    /usr/local/go/bin
    /usr/local/scripts/shell
    /usr/local/scripts/python
)

if { fn-is-os mac } tool_bins+=(
    /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Support
    /opt/local/bin
    /opt/X11/bin
    /opt/homebrew/lib/ruby/gems/*/bin(N)
    /opt/homebrew/opt/ruby/bin
)

fn-insert path $tool_bins
fn-insert path ${XDG_BIN_HOME}
##[<] 🤖🤖
