##[>] 🤖🤖
if [[ -z ${TMUX} ]] {
  __tmux_base="${${PWD:t}//[.:]/_}"
  __tmux_name=$__tmux_base
  __tmux_i=2
  while { tmux has-session -t "=$__tmux_name" 2>/dev/null } {
    __tmux_name="$__tmux_base-$((__tmux_i++))"
  }
  tmux new-session -s "$__tmux_name"
}
##[<] 🤖🤖
