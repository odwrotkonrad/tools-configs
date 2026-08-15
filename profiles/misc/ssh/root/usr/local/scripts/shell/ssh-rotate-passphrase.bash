#!/opt/homebrew/bin/bash
set -euo pipefail

name="${1}"
keyfile="$HOME/.ssh/$name"
if [ ! -f "$keyfile" ]; then
##[>] 🤖🤖
	echo "key doesn't exist: $keyfile" >&2
##[<] 🤖🤖
	exit 1
fi

vault="ProgrammaticAccess"
item="ssh_$name"

old=$(op read "op://$vault/$item/password")
new=$(openssl rand -base64 30)

op item edit "$item" --vault "$vault" "password=$new"
ssh-keygen -p -P "$old" -N "$new" -f "$keyfile"

echo "rotated $item"
