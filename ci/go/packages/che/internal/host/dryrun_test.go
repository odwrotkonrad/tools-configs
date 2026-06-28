package host

// [>] 🤖🤖

import (
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"

	"configs/ci/go/packages/che/internal/spec"
	"configs/ci/go/packages/che/internal/testutil"
)

// setupHost builds the canonical mock che repo (HOME + a tree covering every pass),
// then returns a dry-run Host + resolved spec + the repo dir.
func setupHost(t *testing.T) (Host, spec.Resolved, string) {
	t.Helper()
	dir, home := testutil.CheRepo(t)
	h := New(dir, home, testutil.CheProfile, true)
	s, err := spec.Load(filepath.Join(dir, "che.yml"))
	if err != nil {
		t.Fatal(err)
	}
	res, err := s.Resolve(testutil.CheProfile, h.Root)
	if err != nil {
		t.Fatal(err)
	}
	return h, res, dir
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
		switch {
		case fi.IsDir():
			lines = append(lines, "d "+rel)
		case fi.Mode()&os.ModeSymlink != 0:
			target, _ := os.Readlink(p)
			lines = append(lines, "l "+rel+" -> "+target)
		default:
			b, _ := os.ReadFile(p)
			lines = append(lines, "f "+rel+" = "+string(b))
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	slices.Sort(lines)
	return strings.Join(lines, "\n")
}

// each pass's dry-run: prints actions, mutates nothing.
func TestDryRunPasses(t *testing.T) {
	cases := []struct {
		name    string
		run     func(Host, spec.Resolved) error
		mustLog string // a verb the dry-run output must contain
	}{
		{"link", func(h Host, r spec.Resolved) error { return h.MkLinks(r.Links, r.Dirs) }, "ln:"},
		{"copy", func(h Host, r spec.Resolved) error { return h.MkCopies(r.Copies, r.Dirs) }, "cp:"},
		{"render-templates", func(h Host, r spec.Resolved) error { return h.RenderTemplates(r.Templates) }, "render:"},
		{"mk-dirs", func(h Host, r spec.Resolved) error { return h.MkDirs(r.Dirs, r.ExtraDirs) }, "mkdir:"},
		{"prune-links", func(h Host, r spec.Resolved) error { return h.PruneBrokenLinks(r.Dirs) }, "prune-links:"},
		{"install-tools", func(h Host, r spec.Resolved) error {
			scripts, err := h.ResolveInstall(r.Installs)
			if err != nil {
				return err
			}
			return h.Install(scripts)
		}, "install:"},
		{"services bootout", func(h Host, r spec.Resolved) error {
			svcs, err := h.ResolveServices(r.Services)
			if err != nil {
				return err
			}
			return h.Bootout(svcs)
		}, "bootout:"},
		{"services bootin", func(h Host, r spec.Resolved) error {
			svcs, err := h.ResolveServices(r.Services)
			if err != nil {
				return err
			}
			return h.Bootin(svcs)
		}, "bootstrap:"},
		{"services ensure", func(h Host, r spec.Resolved) error {
			svcs, err := h.ResolveServices(r.Services)
			if err != nil {
				return err
			}
			return h.Ensure(svcs)
		}, "ensure:"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			h, res, dir := setupHost(t)
			before := snapshotTree(t, dir)

			out, err := testutil.CaptureStdout(t, func() error { return c.run(h, res) })
			if err != nil {
				t.Fatalf("%s dry-run errored: %v", c.name, err)
			}
			if !strings.Contains(out, c.mustLog) {
				t.Errorf("%s dry-run printed no %q action:\n%s", c.name, c.mustLog, out)
			}
			for line := range strings.SplitSeq(strings.TrimSpace(out), "\n") {
				if line != "" && !strings.Contains(line, "[dry-run]") {
					t.Errorf("%s printed a non-dry-run line: %q", c.name, line)
				}
			}
			if after := snapshotTree(t, dir); after != before {
				t.Errorf("%s dry-run mutated the tree:\nBEFORE:\n%s\nAFTER:\n%s", c.name, before, after)
			}
		})
	}
}

// [<] 🤖🤖
