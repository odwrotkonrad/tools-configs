#[what] config for claude spawned shells only

if (( ! ${+CLAUDECODE})) return 0


#[what] render manpage as plain text
function man {
  mandoc -T utf8 -O indent=0 "$(/usr/bin/man -w "$@")" \
    | col -bx \
    | sed 's/^[[:space:]]*//' \
    | cat -s
}
