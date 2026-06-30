ko ALL=(root) NOPASSWD: SETENV: {{ env.Getenv "GOPATH" | default (printf "%s/go" (env.Getenv "HOME")) }}/bin/che *
