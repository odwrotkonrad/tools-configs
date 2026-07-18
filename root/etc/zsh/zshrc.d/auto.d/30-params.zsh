typeset -A zsh_params=(
  HISTSIZE    15_000
  SAVEHIST    10_000
  ##[>] 🤖🤖
  KEYTIMEOUT  1         #[what] centiseconds zle waits to disambiguate a key sequence: 10ms (default 400ms) so a bare ESC dismisses the completion menu near-instantly; safe because arrow/alt ESC-sequences arrive from the terminal as one atomic burst
  ##[<] 🤖🤖
  histchars   '!^#'     #[what] histexpand-char quicksubst-char comment-char (defaults)
  ##[>] 🤖🤖
  PS1         '%$((COLUMNS-3))<...<$(_cd_deep_shortpwd $PWD)%<< %# ' #[what] abbreviated cwd (left-truncated to fit width) prompt-sigil (%#: # root, %% user)
  ##[<] 🤖🤖
  PS2         '> '      #[what] continuation-line prompt
  PS4         '+ '      #[what] prompt when debugging prompt with XTRACE is set
)
for k v in "${(@kv)zsh_params}"; typeset -g "$k=$v"
##[>] 🤖🤖
if { fn-is-virt } PS1="(virt) $PS1"
##[<] 🤖🤖
