package main

// [>] 🤖🤖🤖

import (
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"testing"
)

const dryRunSpec = `
profiles:
  virt:
    mac-os-aarch64:
base-cli:
  load-configuration:
    HOME/.config/zsh/**:
    etc/zshrc:
    etc/zsh/**:
  make-extra-dirs:
    - HOME/.cache/zsh
    - /tmp/che-dryrun-extra
  install:
    - install/unit
virt/mac-os-aarch64:
  include-profiles: [base-cli]
`

// dryRunApp builds a fixture repo with a real on-disk HOME, a copy-able dest, a
// template, and a real install script, then returns a dry-run app for it.
func dryRunApp(t *testing.T) *app {
	t.Helper()
	dir := t.TempDir()
	home := filepath.Join(dir, "home")
	files := map[string]string{
		"root/etc/zshrc":                         "zshrc\n",
		"root/etc/zsh/zshenv":                    "env\n",
		"root/HOME/.config/zsh/.zshrc":           "user zshrc\n",
		"root/HOME/.config/zsh/c.host.auto.cp":   "copyme\n",
		"root/HOME/.config/zsh/t.host.auto.tmpl": "plain template\n",
		"install/unit":                           "#!/bin/sh\necho ran\n",
	}
	for rel, body := range files {
		p := filepath.Join(dir, rel)
		if err := os.MkdirAll(filepath.Dir(p), 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(body), 0755); err != nil {
			t.Fatal(err)
		}
	}
	if err := os.MkdirAll(home, 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, "che.yml"), []byte(dryRunSpec), 0644); err != nil {
		t.Fatal(err)
	}
	for _, args := range [][]string{
		{"init", "-q"},
		{"-c", "core.excludesfile=", "add", "-Af"},
		{"-c", "user.email=t@t", "-c", "user.name=t", "-c", "commit.gpgsign=false", "commit", "-qm", "x"},
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
	eff, err := s.resolveEffective("virt/mac-os-aarch64")
	if err != nil {
		t.Fatal(err)
	}
	return &app{
		repoRoot: dir,
		root:     filepath.Join(dir, "root"),
		home:     home,
		profile:  "virt/mac-os-aarch64",
		space:    "virt",
		spec:     s,
		eff:      eff,
		dryRun:   true,
	}
}

// snapshotTree records every path + content under dir (sorted), so a before/after
// comparison can prove a dry-run mutated nothing.
func snapshotTree(t *testing.T, dir string) string {
	t.Helper()
	var lines []string
	err := filepath.Walk(dir, func(p string, fi os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(dir, p)
		if fi.IsDir() {
			lines = append(lines, "d "+rel)
			return nil
		}
		if fi.Mode()&os.ModeSymlink != 0 {
			target, _ := os.Readlink(p)
			lines = append(lines, "l "+rel+" -> "+target)
			return nil
		}
		b, _ := os.ReadFile(p)
		lines = append(lines, "f "+rel+" = "+string(b))
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	sort.Strings(lines)
	return strings.Join(lines, "\n")
}

// captureStdout runs fn with os.Stdout redirected to a pipe, returns what it printed.
func captureStdout(t *testing.T, fn func() error) (string, error) {
	t.Helper()
	orig := os.Stdout
	r, w, err := os.Pipe()
	if err != nil {
		t.Fatal(err)
	}
	os.Stdout = w
	runErr := fn()
	w.Close()
	os.Stdout = orig
	out, _ := io.ReadAll(r)
	return string(out), runErr
}

// each subcommand's dry-run: prints actions, mutates nothing.
func TestDryRunPasses(t *testing.T) {
	cases := []struct {
		name    string
		pass    func(*app) error
		mustLog string // a verb the dry-run output must contain
	}{
		{"link", (*app).passLink, "ln:"},
		{"copy", (*app).passCopy, "cp:"},
		{"render-templates", (*app).passTmpl, "render:"},
		{"mk-dirs", (*app).passDirs, "mkdir:"},
		{"prune-links", (*app).passPrune, "prune-links:"},
		{"install-tools", (*app).passInstall, "install:"},
		{"sync", (*app).sync, "ln:"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			a := dryRunApp(t)
			// snapshot the whole repo dir (root + home + dirs) before
			before := snapshotTree(t, a.repoRoot)

			out, err := captureStdout(t, func() error { return c.pass(a) })
			if err != nil {
				t.Fatalf("%s dry-run errored: %v", c.name, err)
			}

			// 1. it printed the expected action verb
			if !strings.Contains(out, c.mustLog) {
				t.Errorf("%s dry-run printed no %q action:\n%s", c.name, c.mustLog, out)
			}
			// 2. every printed line is tagged [dry-run]
			for line := range strings.SplitSeq(strings.TrimSpace(out), "\n") {
				if line != "" && !strings.Contains(line, "[dry-run]") {
					t.Errorf("%s printed a non-dry-run line: %q", c.name, line)
				}
			}
			// 3. it mutated nothing
			if after := snapshotTree(t, a.repoRoot); after != before {
				t.Errorf("%s dry-run mutated the tree:\nBEFORE:\n%s\nAFTER:\n%s", c.name, before, after)
			}
		})
	}
}

// [<] 🤖🤖🤖
