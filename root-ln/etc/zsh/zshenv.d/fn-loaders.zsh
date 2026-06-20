##[>] 🤖🤖
#[what] autoload every function file in each given dir (defined inline, cannot itself be autoloaded)
fn-rt-autoload-functions() {
  local d f
  for d; do
    for f in ${d}/*(N:t); {
      emulate zsh -LRc "autoload $f"
    }
  done
}

#[what] source every regular file (incl. symlinks) in each given dir, name order, skip *.tmpl
fn-rt-source() {
  for d; do
    for rc in ${d}/*(Non); {
      [[ -d $rc || $rc == *.tmpl ]] && continue
      . $rc

    }
  done
}

#[what] prepend args to the named array, keeping first occurrence unique: fn-rt-insert <array> item...
fn-rt-insert() {
  local name=$1; shift
  set -A $name "$@" "${(@P)name}"
  set -A $name "${(@Pu)name}"
}
##[<] 🤖🤖
