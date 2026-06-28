##[>] 🤖🤖
#[what] autoload function files in each dir (inline, cannot self-autoload)
fn-autoload-functions() {
  local d f
  for d; do
    for f in ${d}/*(N:t); {
      emulate zsh -LRc "autoload $f"
    }
  done
}

#[what] source regular files in each dir, name order, skip *.tmpl
fn-source() {
  for d; do
    for rc in ${d}/*(Non); {
      [[ -d $rc || $rc == *.tmpl ]] && continue
      . $rc

    }
  done
}

#[what] prepend args to named array, first occurrence unique: fn-insert <array> item...
fn-insert() {
  local name=$1; shift
  set -A $name "$@" "${(@P)name}"
  set -A $name "${(@Pu)name}"
}
##[<] 🤖🤖
