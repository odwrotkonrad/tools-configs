#[what] 2nd file sourced after /etc/zshenv

typeset -a bins=(
    ${XDG_BIN_HOME}
    /usr/local/bin
)

##[>] 🤖🤖
if { fn-is-os mac } bins+=(
    /opt/homebrew/bin
)

if { fn-is-os linux } bins+=(
    /home/linuxbrew/.linuxbrew/bin
)
##[<] 🤖🤖

bins+=(
    /usr/bin
    /usr/sbin
    /bin
    /sbin
)

fn-insert path $bins

typeset -a funcs=(
    ${XDG_CONFIG_HOME}/zsh/zshenv.d/functions
)

fn-insert fpath $funcs
fn-autoload-functions $funcs
fn-source ${XDG_CONFIG_HOME}/zsh/zshenv.d/auto.d
