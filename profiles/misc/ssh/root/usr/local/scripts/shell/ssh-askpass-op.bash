#!/bin/bash

key_name=$(echo "$1" | rg -o '/(\w+)\W*$' -r '$1')
op read "op://ProgrammaticAccess/ssh_$key_name/password"
