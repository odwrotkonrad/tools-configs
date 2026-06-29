package spec

// [>] 🤖🤖

import (
	"maps"
	"path/filepath"
	"slices"
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// fixtureRepo commits a git repo from files plus che.yml fixture
// (testutil/specs/<spec>.yml), returns dir.
func fixtureRepo(t *testing.T, spec string, files map[string]string) string {
	t.Helper()
	files = maps.Clone(files)
	files["che.yml"] = testutil.Spec(t, spec)
	return testutil.Repo(t, files)
}

func resolve(t *testing.T, dir, profile string) Resolved {
	t.Helper()
	s, err := Load(filepath.Join(dir, "che.yml"))
	if err != nil {
		t.Fatal(err)
	}
	res, err := s.Resolve(profile, filepath.Join(dir, "root"))
	if err != nil {
		t.Fatal(err)
	}
	return res
}

var mergeFiles = map[string]string{
	"root/etc/zshrc":               "zshrc\n",
	"root/HOME/.config/zsh/.zshrc": "user zshrc\n",
	"root/etc/grafana/grafana.ini": "ini\n",
}

// hasLink reports whether res.Links carries a file with the given rel.
func hasLink(res Resolved, rel string) bool {
	return slices.ContainsFunc(res.Links, func(it FileItem) bool { return it.Rel == rel })
}

func TestResolveMerge(t *testing.T) {
	dir := fixtureRepo(t, "merge", mergeFiles)

	// desktop: base, everything present.
	host := resolve(t, dir, "desktop/macos")
	wantInstall := []string{
		"ci/zsh/scripts/installs/10-brew.zsh",
		"ci/zsh/scripts/installs/20-kitty.zsh",
	}
	if !slices.Equal(host.Installs, wantInstall) {
		t.Errorf("host install order = %v, want %v", host.Installs, wantInstall)
	}
	if !hasDir(host, "/var/log/grafana") || !hasDir(host, "HOME/.cache/zsh") {
		t.Errorf("host dirs missing merge: %v", dirPaths(host.ExtraDirs))
	}
	if d := findDir(host, "/var/log/grafana"); d == nil || d.Chmod != "2775" {
		t.Errorf("grafana dir lost spec chmod: %+v", d)
	}
	wantServices := []string{"otelcol", "port-exporter", "grafana", "prometheus"}
	if !slices.Equal(host.Services, wantServices) {
		t.Errorf("host services = %v, want %v", host.Services, wantServices)
	}
	if !hasLink(host, "etc/grafana/grafana.ini") {
		t.Errorf("host missing grafana link: %v", host.Links)
	}

	// cli: base minus exclude-desktop.
	vm := resolve(t, dir, "cli/macos")
	if !slices.Equal(vm.Installs, []string{"ci/zsh/scripts/installs/10-brew.zsh"}) {
		t.Errorf("vm install = %v, want brew only", vm.Installs)
	}
	if hasDir(vm, "/var/log/grafana") {
		t.Errorf("vm must not keep desktop dirs: %v", dirPaths(vm.ExtraDirs))
	}
	if !slices.Equal(vm.Services, []string{"otelcol", "port-exporter"}) {
		t.Errorf("vm services = %v, want desktop excluded: %v", vm.Services, vm.Services)
	}
	if hasLink(vm, "etc/grafana/grafana.ini") {
		t.Errorf("vm kept desktop-only grafana: %v", vm.Links)
	}
}

func TestResolveClassify(t *testing.T) {
	files := map[string]string{
		"root/etc/zshrc":                                   "zshrc\n",
		"root/etc/zsh/zshenv":                              "env\n",
		"root/HOME/.config/zsh/.zshrc":                     "user zshrc\n",
		"root/HOME/.config/git/config":                     "[user]\n",
		"root/HOME/.config/zsh/x.host.cp":                  "copyme\n",
		"root/HOME/.config/zsh/y.host.tpl":                 "tmpl\n",
		"root/HOME/.config/zsh/.gitkeep":                   "",
		"root/etc/grafana/grafana.ini":                     "ini\n",
		"root/Library/LaunchDaemons/otelcol.plist.host.cp": "plist\n",
	}
	dir := fixtureRepo(t, "classify", files)
	cs := resolve(t, dir, "cli/macos")
	wantLinks := []string{
		"HOME/.config/git/config",
		"HOME/.config/zsh/.zshrc",
		"etc/zsh/zshenv",
		"etc/zshrc",
	}
	if !slices.Equal(rels(cs.Links), wantLinks) {
		t.Errorf("links = %v, want %v", rels(cs.Links), wantLinks)
	}
	if !slices.Equal(rels(cs.Copies), []string{
		"HOME/.config/zsh/x.host.cp",
		"Library/LaunchDaemons/otelcol.plist.host.cp",
	}) {
		t.Errorf("copies = %v", rels(cs.Copies))
	}
	if !slices.Equal(rels(cs.Templates), []string{"HOME/.config/zsh/y.host.tpl"}) {
		t.Errorf("templates = %v", rels(cs.Templates))
	}
	for _, l := range rels(cs.Links) {
		if filepath.Base(l) == ".gitkeep" {
			t.Errorf(".gitkeep leaked into links")
		}
	}
	if !slices.Contains(cs.Dirs, "HOME") || !slices.Contains(cs.Dirs, "HOME/.config/zsh") {
		t.Errorf("dirs missing ancestors: %v", cs.Dirs)
	}
}

// rels extracts the Rel of each FileItem.
func rels(items []FileItem) []string {
	out := make([]string, len(items))
	for i, it := range items {
		out[i] = it.Rel
	}
	return out
}

// dirPaths extracts the first dest path of each dir FileItem.
func dirPaths(items []FileItem) []string {
	out := make([]string, len(items))
	for i, it := range items {
		out[i] = it.Dests[0].Path
	}
	return out
}

// hasDir reports whether res.ExtraDirs carries the given path.
func hasDir(res Resolved, path string) bool { return findDir(res, path) != nil }

// findDir returns the dir FileItem with the given dest path, or nil.
func findDir(res Resolved, path string) *FileItem {
	for i, it := range res.ExtraDirs {
		if it.Dests[0].Path == path {
			return &res.ExtraDirs[i]
		}
	}
	return nil
}

func TestResolveUndefinedFails(t *testing.T) {
	dir := fixtureRepo(t, "merge", mergeFiles)
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("cli/linux", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected error for declared-but-undefined profile")
	}
}

func TestMixinProfilesCycle(t *testing.T) {
	dir := fixtureRepo(t, "cycle", map[string]string{"root/.gitkeep": ""})
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("cli/macos", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected cycle error")
	}
}

// TestIncludeExcludeSections: exclude wins over explicit include across every
// key (glob match, not exact), including rich {source,dest} entries.
func TestIncludeExcludeSections(t *testing.T) {
	files := map[string]string{
		"root/etc/zshrc":                  "z\n",
		"root/etc/zsh/zshenv":             "e\n", // excluded -> must not link
		"root/HOME/.config/extra/x":       "x\n",
		"root/HOME/.config/oneoff/y":      "y\n",
		"root/HOME/.config/zsh/c.host.cp": "c\n", // rich copy, excluded by glob
	}
	dir := fixtureRepo(t, "include-exclude", files)
	res := resolve(t, dir, "cli/macos")

	if !hasLink(res, "HOME/.config/extra/x") {
		t.Errorf("include.link extra not merged: %v", rels(res.Links))
	}
	if !hasLink(res, "etc/zshrc") {
		t.Errorf("etc/zshrc include missing: %v", rels(res.Links))
	}
	if hasLink(res, "etc/zsh/zshenv") {
		t.Errorf("exclude.link glob not applied: %v", rels(res.Links))
	}
	if slices.ContainsFunc(res.Copies, func(it FileItem) bool { return it.Rel == "HOME/.config/zsh/c.host.cp" }) {
		t.Errorf("exclude.copy glob did not drop rich entry: %v", rels(res.Copies))
	}
	if !slices.Contains(res.Installs, "ci/zsh/scripts/installs/10-brew.zsh") {
		t.Errorf("include.install brew missing: %v", res.Installs)
	}
	if slices.Contains(res.Installs, "ci/zsh/scripts/installs/20-foo.zsh") {
		t.Errorf("exclude.install did not remove foo: %v", res.Installs)
	}
	if slices.Contains(res.Services, "grafana") {
		t.Errorf("exclude.services glob did not remove grafana: %v", res.Services)
	}
	if !slices.Contains(res.Services, "otelcol") {
		t.Errorf("otelcol service missing: %v", res.Services)
	}
}

func TestMixinProfilesUndefined(t *testing.T) {
	dir := fixtureRepo(t, "undefined-include", map[string]string{"root/.gitkeep": ""})
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("cli/macos", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected undefined-include error")
	}
}

// [<] 🤖🤖
