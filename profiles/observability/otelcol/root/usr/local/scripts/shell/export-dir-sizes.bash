#!/bin/bash

set -u

host=localhost
port=9102

interval=300

min_bytes=$((10 * 1024 * 1024))

cache=/var/custom/cache/dir_size_exporter/dir_sizes.prom

roots=(
  /opt
  /usr/local
  /Library
  /private/var
  /private/etc
  /private/tmp
)

for home in /Users/*; do
  case ${home##*/} in
    Shared | .localized) continue ;;
  esac
  [ -d "$home" ] && roots+=("$home")
done

collect() {
  echo "# HELP dir_size_bytes Directory size in bytes (du)."
  echo "# TYPE dir_size_bytes gauge"

  local -a paths=() sizes=()
  local root kib path
  for root in "${roots[@]}"; do
    [ -d "$root" ] || continue
    while IFS=$'\t' read -r kib path; do
      [ -n "$kib" ] || continue
      local bytes=$((kib * 1024))
      [ "$bytes" -ge "$min_bytes" ] || continue
      paths+=("$path")
      sizes+=("$bytes")
    done < <(du -d 3 -x "$root" 2>/dev/null)
  done

  local i j n=${#paths[@]} is_ancestor
  for ((i = 0; i < n; i++)); do
    is_ancestor=0
    for ((j = 0; j < n; j++)); do
      [ "$i" -eq "$j" ] && continue
      case "${paths[j]}/" in
        "${paths[i]}/"*) is_ancestor=1; break ;;
      esac
    done
    [ "$is_ancestor" -eq 1 ] && continue
    local escaped_path=${paths[i]//\\/}
    escaped_path=${escaped_path//\"/}
    echo "dir_size_bytes{path=\"$escaped_path\"} ${sizes[i]}"
  done
}

refresh_cache() {
  local tmp="$cache.tmp.$$"
  collect > "$tmp" 2>/dev/null
  mv -f "$tmp" "$cache"
}

if [ "${1:-}" = "--refresh" ]; then
  refresh_cache
  exit 0
fi

if [ "${1:-}" = "--serve" ]; then
  while IFS= read -r req; do
    req=${req%$'\r'}
    [ -z "$req" ] && break
  done

  body=""
  [ -f "$cache" ] && body=$(cat "$cache")
  if [ -z "$body" ]; then
    body=$'# HELP dir_size_bytes Directory size in bytes (du).\n# TYPE dir_size_bytes gauge'
  fi
  len=${#body}

  printf 'HTTP/1.0 200 OK\r\n'
  printf 'Content-Type: text/plain; version=0.0.4\r\n'
  printf 'Content-Length: %d\r\n' "$len"
  printf 'Connection: close\r\n'
  printf '\r\n'
  printf '%s' "$body"
  exit 0
fi

refresh_cache
(
  while true; do
    sleep "$interval"
    "$0" --refresh
  done
) &

exec /opt/homebrew/bin/ncat -lk "$host" "$port" -c "$0 --serve"
