#[what] 2nd file sourced after /etc/zshenv

##[>] env
setopt allexport

ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/.asdfrc"
ASDF_DATA_DIR="${XDG_STATE_HOME}/asdf"
AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
AZURE_CONFIG_DIR="${XDG_CONFIG_HOME}/azure"
CLOUDSDK_COMPUTE_REGION="europe-west1"
CLOUDSDK_COMPUTE_ZONE="europe-west1-b"
GOPATH="${HOME}/go"
PYENV_ROOT="${HOME}/.pyenv"
PYTHONPATH="/usr/local/scripts/python"

unsetopt allexport
##[<] env

typeset -a bins=(
    ${XDG_BIN_HOME}
    ${GOPATH}/bin
    ${PYENV_ROOT}/bin
    ${PYENV_ROOT}/shims
    ${ASDF_DATA_DIR}/shims
    /usr/local/go/bin
    /usr/local/bin
    /usr/local/scripts/shell
    /usr/local/scripts/installs
    /usr/local/scripts/python
    /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Support
    /opt/local/bin
    /opt/X11/bin
    /opt/homebrew/lib/ruby/gems/*/bin(N)
    /opt/homebrew/opt/ruby/bin
    /opt/homebrew/bin
    /usr/bin
    /usr/sbin
    /bin
    /sbin
)

fn-root-insert path $bins

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions
)

fn-root-insert fpath $funcs
fn-root-autoload-functions $funcs
fn-root-source ${XDG_CONFIG_HOME}/zsh/zshenv.d/auto.d
