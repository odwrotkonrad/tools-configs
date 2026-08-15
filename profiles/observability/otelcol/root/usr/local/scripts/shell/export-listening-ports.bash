#!/bin/bash

set -u

host=localhost
port=9101

ephemeral_port_min=49152

collect() {
  echo "# HELP listening_port Local TCP port in LISTEN state (value always 1)."
  echo "# TYPE listening_port gauge"

  local pid cmd ppid
  /usr/sbin/lsof -nP -iTCP -sTCP:LISTEN -FpcRn 2>/dev/null | while IFS= read -r line; do
    case ${line:0:1} in
      p) pid=${line:1} ;;
      c) cmd=${line:1} ;;
      R) ppid=${line:1} ;;
      n)
        local addr=${line:1}
        local port=${addr##*:}
        case $port in
          ''|*[!0-9]*) continue ;;
        esac
        if [ "$port" -lt "$ephemeral_port_min" ]; then
          local escaped_cmd=${cmd//\\/}
          escaped_cmd=${escaped_cmd//\"/}
          echo "listening_port{port=\"$port\",process=\"$escaped_cmd\",pid=\"$pid\",ppid=\"$ppid\"} 1"
        fi
        ;;
    esac
  done | sort -u
}

serve_once() {
  while IFS= read -r req; do
    req=${req%$'\r'}
    [ -z "$req" ] && break
  done

  local body
  body=$(collect)
  local len=${#body}

  printf 'HTTP/1.0 200 OK\r\n'
  printf 'Content-Type: text/plain; version=0.0.4\r\n'
  printf 'Content-Length: %d\r\n' "$len"
  printf 'Connection: close\r\n'
  printf '\r\n'
  printf '%s' "$body"
}

if [ "${1:-}" = "--serve" ]; then
  serve_once
  exit 0
fi

exec /opt/homebrew/bin/ncat -lk "$host" "$port" -c "$0 --serve"
