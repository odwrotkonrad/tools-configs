package main

// [>] 🤖🤖🤖

import "testing"

func TestNormalize(t *testing.T) {
	osCases := map[string]string{"darwin": "mac-os", "linux": "linux"}
	for in, want := range osCases {
		if got := normalizeOS(in); got != want {
			t.Errorf("normalizeOS(%q) = %q, want %q", in, got, want)
		}
	}
	archCases := map[string]string{"arm64": "aarch64", "amd64": "x86"}
	for in, want := range archCases {
		if got := normalizeArch(in); got != want {
			t.Errorf("normalizeArch(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestToDest(t *testing.T) {
	a := &app{home: "/Users/x"}
	cases := map[string]string{
		"HOME":                                "/Users/x",
		"HOME/.config/zsh":                    "/Users/x/.config/zsh",
		"etc/zshrc":                           "/etc/zshrc",
		"/var/custom/cache/dir_size_exporter": "/var/custom/cache/dir_size_exporter",
		"/var/log/otelcol":                    "/var/log/otelcol",
	}
	for in, want := range cases {
		if got := a.toDest(in); got != want {
			t.Errorf("toDest(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestExtractDryRun(t *testing.T) {
	cases := []struct {
		in      []string
		wantCmd string
		wantDry bool
	}{
		{[]string{"link"}, "link", false},
		{[]string{"--dry-run", "link"}, "link", true},
		{[]string{"link", "--dry-run"}, "link", true},
		{[]string{"sync"}, "sync", false},
	}
	for _, c := range cases {
		args, dry := extractDryRun(c.in)
		if len(args) == 0 || args[0] != c.wantCmd || dry != c.wantDry {
			t.Errorf("extractDryRun(%v) = (%v, %v), want cmd %q dry %v", c.in, args, dry, c.wantCmd, c.wantDry)
		}
	}
}

// [<] 🤖🤖🤖
