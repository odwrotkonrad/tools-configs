##[>] 🤖🤖
if [[ -z ${TMUX} ]] {
  exec tmux new-session -A -s "${${PWD:t}//[.:]/_}"
}
##[<] 🤖🤖
