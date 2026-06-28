package main

// [>] 🤖🤖🤖

import (
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"testing"
)

// fixtureRepo builds a temp git repo with a root/ tree + che.yml, returns an app
// resolved for the given profile.
func fixtureRepo(t *testing.T, profile string) *app {
	t.Helper()
	dir := t.TempDir()
	files := map[string]string{
		"root/etc/zshrc":                                               "zshrc\n",
		"root/etc/zsh/zshenv":                                          "env\n",
		"root/HOME/.config/zsh/.zshrc":                                 "user zshrc\n",
		"root/HOME/.config/git/config":                                 "[user]\n",
		"root/HOME/.config/zsh/x.host.auto.cp":                         "copyme\n",
		"root/HOME/.config/zsh/y.host.auto.tmpl":                       "tmpl\n",
		"root/HOME/.config/zsh/.gitkeep":                               "",
		"root/etc/grafana/grafana.ini":                                 "ini\n", // host-only, excluded for vm
		"root/Library/LaunchDaemons/d-root-otelcol.plist.host.auto.cp": "plist\n",
	}
	for rel, body := range files {
		p := filepath.Join(dir, rel)
		if err := os.MkdirAll(filepath.Dir(p), 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(body), 0644); err != nil {
			t.Fatal(err)
		}
	}
	if err := os.WriteFile(filepath.Join(dir, "che.yml"), []byte(fixtureSpecResolve), 0644); err != nil {
		t.Fatal(err)
	}
	for _, args := range [][]string{
		{"init", "-q"},
		{"-c", "core.excludesfile=", "add", "-Af"}, // -f: global ignore drops dotfiles
		{"-c", "user.email=t@t", "-c", "user.name=t", "commit", "-qm", "x"},
	} {
		c := exec.Command("git", args...)
		c.Dir = dir
		if out, err := c.CombinedOutput(); err != nil {
			t.Fatalf("git %v: %v\n%s", args, err, out)
		}
	}
	s, err := loadSpec(filepath.Join(dir, "che.yml"))
	if err != nil {
		t.Fatal(err)
	}
	eff, err := s.resolveEffective(profile)
	if err != nil {
		t.Fatal(err)
	}
	return &app{repoRoot: dir, root: filepath.Join(dir, "root"), home: "/h", profile: profile, spec: s, eff: eff}
}

const fixtureSpecResolve = `
profiles:
  virt:
    mac-os-aarch64:
  bare-metal:
    mac-os-aarch64:
base-cli:
  load-configuration:
    HOME/.config/zsh/**:
    HOME/.config/git/**:
    etc/zshrc:
    etc/zsh/**:
    Library/LaunchDaemons/d-root-otelcol.plist*:
base-desktop:
  load-configuration:
    etc/grafana/**:
virt/mac-os-aarch64:
  include-profiles: [base-cli]
bare-metal/mac-os-aarch64:
  include-profiles: [base-cli, base-desktop]
`

func TestResolveConfigsClassify(t *testing.T) {
	a := fixtureRepo(t, "virt/mac-os-aarch64")
	cs, err := a.resolveConfigs()
	if err != nil {
		t.Fatal(err)
	}
	wantLinks := []string{
		"HOME/.config/git/config",
		"HOME/.config/zsh/.zshrc",
		"etc/zsh/zshenv",
		"etc/zshrc",
	}
	if !slices.Equal(cs.links, wantLinks) {
		t.Errorf("links = %v, want %v", cs.links, wantLinks)
	}
	if !slices.Equal(cs.copies, []string{
		"HOME/.config/zsh/x.host.auto.cp",
		"Library/LaunchDaemons/d-root-otelcol.plist.host.auto.cp",
	}) {
		t.Errorf("copies = %v", cs.copies)
	}
	if !slices.Equal(cs.templates, []string{"HOME/.config/zsh/y.host.auto.tmpl"}) {
		t.Errorf("templates = %v", cs.templates)
	}
	// .gitkeep excluded everywhere
	for _, l := range cs.links {
		if filepath.Base(l) == ".gitkeep" {
			t.Errorf(".gitkeep leaked into links")
		}
	}
	// vm must not pick host-only grafana
	if slices.Contains(cs.links, "etc/grafana/grafana.ini") {
		t.Errorf("vm picked host-only grafana")
	}
	// dirs include ancestors, parents before children
	if !slices.Contains(cs.dirs, "HOME") || !slices.Contains(cs.dirs, "HOME/.config/zsh") {
		t.Errorf("dirs missing ancestors: %v", cs.dirs)
	}
}

func TestResolveConfigsHostAddsGrafana(t *testing.T) {
	a := fixtureRepo(t, "bare-metal/mac-os-aarch64")
	cs, err := a.resolveConfigs()
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Contains(cs.links, "etc/grafana/grafana.ini") {
		t.Errorf("host missing grafana: %v", cs.links)
	}
}

// [<] 🤖🤖🤖
