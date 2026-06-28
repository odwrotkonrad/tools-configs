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

func TestResolveMerge(t *testing.T) {
	dir := fixtureRepo(t, "merge", mergeFiles)

	// host: base + leaf appended.
	host := resolve(t, dir, "bare-metal/mac-os-aarch64")
	wantInstall := []string{
		"ci/zsh/scripts/installs/mac/brew.zsh",
		"ci/zsh/scripts/installs/mac/kitty.zsh",
	}
	if !slices.Equal(host.Installs, wantInstall) {
		t.Errorf("host install order = %v, want %v", host.Installs, wantInstall)
	}
	if !slices.Contains(host.ExtraDirs, "/var/log/grafana") || !slices.Contains(host.ExtraDirs, "HOME/.cache/zsh") {
		t.Errorf("host dirs missing merge: %v", host.ExtraDirs)
	}
	wantServices := []string{"otelcol", "port-exporter", "grafana", "prometheus"}
	if !slices.Equal(host.Services, wantServices) {
		t.Errorf("host services = %v, want %v", host.Services, wantServices)
	}
	if !slices.Contains(host.Links, "etc/grafana/grafana.ini") {
		t.Errorf("host missing grafana link: %v", host.Links)
	}

	// vm: empty leaf -> exactly base-cli.
	vm := resolve(t, dir, "virt/mac-os-aarch64")
	if len(vm.Installs) != 1 || vm.Installs[0] != "ci/zsh/scripts/installs/mac/brew.zsh" {
		t.Errorf("vm install = %v, want base only", vm.Installs)
	}
	if slices.Contains(vm.ExtraDirs, "/var/log/grafana") {
		t.Errorf("vm must not inherit host dirs: %v", vm.ExtraDirs)
	}
	if !slices.Equal(vm.Services, []string{"otelcol", "port-exporter"}) {
		t.Errorf("vm services = %v, want base-cli only", vm.Services)
	}
	if slices.Contains(vm.Links, "etc/grafana/grafana.ini") {
		t.Errorf("vm picked host-only grafana: %v", vm.Links)
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
	cs := resolve(t, dir, "virt/mac-os-aarch64")
	wantLinks := []string{
		"HOME/.config/git/config",
		"HOME/.config/zsh/.zshrc",
		"etc/zsh/zshenv",
		"etc/zshrc",
	}
	if !slices.Equal(cs.Links, wantLinks) {
		t.Errorf("links = %v, want %v", cs.Links, wantLinks)
	}
	if !slices.Equal(cs.Copies, []string{
		"HOME/.config/zsh/x.host.cp",
		"Library/LaunchDaemons/otelcol.plist.host.cp",
	}) {
		t.Errorf("copies = %v", cs.Copies)
	}
	if !slices.Equal(cs.Templates, []string{"HOME/.config/zsh/y.host.tpl"}) {
		t.Errorf("templates = %v", cs.Templates)
	}
	for _, l := range cs.Links {
		if filepath.Base(l) == ".gitkeep" {
			t.Errorf(".gitkeep leaked into links")
		}
	}
	if !slices.Contains(cs.Dirs, "HOME") || !slices.Contains(cs.Dirs, "HOME/.config/zsh") {
		t.Errorf("dirs missing ancestors: %v", cs.Dirs)
	}
}

func TestResolveUndefinedFails(t *testing.T) {
	dir := fixtureRepo(t, "merge", mergeFiles)
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("virt/linux-aarch64", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected error for declared-but-undefined profile")
	}
}

func TestIncludeProfilesCycle(t *testing.T) {
	dir := fixtureRepo(t, "cycle", map[string]string{"root/.gitkeep": ""})
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("virt/mac-os-aarch64", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected cycle error")
	}
}

func TestIncludeExcludeSections(t *testing.T) {
	files := map[string]string{
		"root/etc/zshrc":             "z\n",
		"root/etc/zsh/zshenv":        "e\n", // excluded -> must not link
		"root/HOME/.config/extra/x":  "x\n", // via include.profiles
		"root/HOME/.config/oneoff/y": "y\n", // via include.load-configuration
	}
	dir := fixtureRepo(t, "include-exclude", files)
	res := resolve(t, dir, "virt/mac-os-aarch64")

	if !slices.Contains(res.Links, "HOME/.config/extra/x") {
		t.Errorf("include.profiles not merged: %v", res.Links)
	}
	if !slices.Contains(res.Links, "HOME/.config/oneoff/y") {
		t.Errorf("include.load-configuration not added: %v", res.Links)
	}
	if !slices.Contains(res.Links, "etc/zshrc") {
		t.Errorf("etc/zshrc include missing: %v", res.Links)
	}
	if slices.Contains(res.Links, "etc/zsh/zshenv") {
		t.Errorf("exclude.load-configuration not applied: %v", res.Links)
	}
	if !slices.Contains(res.Installs, "ci/zsh/scripts/installs/mac/oneoff") {
		t.Errorf("include.install not added: %v", res.Installs)
	}
	if slices.Contains(res.Installs, "ci/zsh/scripts/installs/mac/brew.zsh") {
		t.Errorf("exclude.install not removed: %v", res.Installs)
	}
	if !slices.Contains(res.Services, "grafana") {
		t.Errorf("include.services not added: %v", res.Services)
	}
	if slices.Contains(res.Services, "otelcol") {
		t.Errorf("exclude.services not removed: %v", res.Services)
	}
}

func TestIncludeProfilesUndefined(t *testing.T) {
	dir := fixtureRepo(t, "undefined-include", map[string]string{"root/.gitkeep": ""})
	s, _ := Load(filepath.Join(dir, "che.yml"))
	if _, err := s.Resolve("virt/mac-os-aarch64", filepath.Join(dir, "root")); err == nil {
		t.Fatal("expected undefined-include error")
	}
}

// [<] 🤖🤖
