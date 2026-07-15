typeset -A zsh_params=(
  HISTSIZE    15_000
  SAVEHIST    10_000
  histchars   '!^#'     #[what] histexpand-char quicksubst-char comment-char (defaults)
  PS1         '$(_cd_deep_shortpwd $PWD) %# ' #[what] abbreviated cwd prompt-sigil (%#: # root, %% user)
  PS2         '> '      #[what] continuation-line prompt
  PS4         '+ '      #[what] prompt when debugging prompt with XTRACE is set
)
for k v in "${(@kv)zsh_params}"; typeset -g "$k=$v"
##[>] 🤖🤖
if { fn-is-virt } PS1="(virt) $PS1"
##[<] 🤖🤖
