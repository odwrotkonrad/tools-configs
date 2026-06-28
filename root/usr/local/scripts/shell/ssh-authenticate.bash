#!/bin/bash

export SSH_ASKPASS="/usr/local/scripts/shell/ssh-askpass-op.bash"
export SSH_ASKPASS_REQUIRE=force

keys=("$HOME/.ssh/id_access" "$HOME/.ssh/id_signing")

loaded=$(ssh-add -l)

for key in "${keys[@]}"; do
	fingerprint=$(ssh-keygen -l -f "$key")
	[[ "$loaded" == *"$fingerprint"* ]] || ssh-add -t 2h "$key"
done
