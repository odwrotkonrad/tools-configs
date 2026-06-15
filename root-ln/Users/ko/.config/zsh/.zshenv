#[≟] 2nd file sourced after /etc/zshenv

#[……] env
setopt allexport

#[…] xdg
XDG_BIN_HOME="${HOME}/.local/bin"               #[≟] xdg - bin recommendation
XDG_CACHE_HOME="${HOME}/.cache"                 #[≟] user-specific non-esseintial data
XDG_CONFIG_HOME="${HOME}/.config"               #[≟] user-specific configuration files
XDG_DATA_HOME="${HOME}/.local/share"            #[≟] user-specific data files
XDG_LOCAL_HOME="${HOME}/.local"
XDG_STATE_HOME="${HOME}/.local/state"           #[≟] user-specific state data
#[⫶] xdg

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
#[⫶⫶] env

typeset -a bins=(
    ${XDG_BIN_HOME}
    ${GOPATH}/bin
    ${PYENV_ROOT}/bin
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

fn-rt-insert path $bins

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions
)

fn-rt-insert fpath $funcs
fn-rt-autoload-functions $funcs
fn-rt-source ${XDG_CONFIG_HOME}/zsh/zshenv.d/auto.d
