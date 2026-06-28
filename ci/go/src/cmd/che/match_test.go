package main

// [>] 🤖🤖🤖

import "testing"

func TestMatchGlob(t *testing.T) {
	cases := []struct {
		pattern, path string
		want          bool
	}{
		{"HOME/.config/zsh/**", "HOME/.config/zsh/.zshrc", true},
		{"HOME/.config/zsh/**", "HOME/.config/zsh/zshrc.d/auto.d/80-tools.zsh", true},
		{"HOME/.config/zsh/**", "HOME/.config/zsh", true},
		{"HOME/.config/zsh/**", "HOME/.config/git/config", false},
		{"HOME/.config/zsh/**", "HOME/.config/zshenv", false}, // prefix not a path boundary
		{"etc/zshrc", "etc/zshrc", true},
		{"etc/zshrc", "etc/zshrc.d/auto.d/x", false},
		{"Library/LaunchDaemons/d-root-otelcol.plist*", "Library/LaunchDaemons/d-root-otelcol.plist", true},
		{"Library/LaunchDaemons/d-root-otelcol.plist*", "Library/LaunchDaemons/d-root-otelcol.plist.host.auto.cp", true},
		{"Library/LaunchDaemons/d-root-otelcol.plist*", "Library/LaunchDaemons/d-root-grafana.plist", false},
		{"etc/otelcol/**", "etc/otelcol/config.yml", true},
	}
	for _, c := range cases {
		if got := matchGlob(c.pattern, c.path); got != c.want {
			t.Errorf("matchGlob(%q, %q) = %v, want %v", c.pattern, c.path, got, c.want)
		}
	}
}

// [<] 🤖🤖🤖
