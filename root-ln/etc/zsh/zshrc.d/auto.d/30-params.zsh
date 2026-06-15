typeset -A zsh_params=(
  HISTSIZE    15_000
  SAVEHIST    10_000
  histchars   '!^#'     #[≟] histexpand-char quicksubst-char comment-char (defaults)
  PS1         '%1~ %# ' #[≟] cwd-basename prompt-sigil (%#: # root, %% user)
  PS2         '> '      #[≟] continuation-line prompt
  PS4         '+ '      #[≟] prompt when debugging prompt with XTRACE is set
)
for k v in "${(@kv)zsh_params}"; typeset -g "$k=$v"
