package main

// [>] 🤖🤖🤖

import (
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"testing"
)

const fixtureSpec = `
profiles:
  bare-metal:
    mac-os-aarch64:
  virt:
    mac-os-aarch64:
    linux-aarch64:

base-cli:
  load-configuration:
    etc/zshrc:
    HOME/.config/zsh/**:
  make-extra-dirs:
    - HOME/.cache/zsh
  install:
    - ci/zsh/scripts/installs/mac/brew

base-desktop:
  load-configuration:
    etc/grafana/**:
  make-extra-dirs:
    - /var/log/grafana
  install:
    - ci/zsh/scripts/installs/mac/kitty

virt/mac-os-aarch64:
  include-profiles: [base-cli]

bare-metal/mac-os-aarch64:
  include-profiles: [base-cli, base-desktop]
`

func writeSpec(t *testing.T) *spec {
	t.Helper()
	dir := t.TempDir()
	p := filepath.Join(dir, "che.yml")
	if err := os.WriteFile(p, []byte(fixtureSpec), 0644); err != nil {
		t.Fatal(err)
	}
	s, err := loadSpec(p)
	if err != nil {
		t.Fatal(err)
	}
	return s
}

func TestResolveEffectiveMerge(t *testing.T) {
	s := writeSpec(t)

	// host: base + leaf appended.
	host, err := s.resolveEffective("bare-metal/mac-os-aarch64")
	if err != nil {
		t.Fatal(err)
	}
	wantInstall := []string{
		"ci/zsh/scripts/installs/mac/brew",
		"ci/zsh/scripts/installs/mac/kitty",
	}
	if !reflect.DeepEqual(host.install, wantInstall) {
		t.Errorf("host install order = %v, want %v", host.install, wantInstall)
	}
	if !contains(host.dirs, "/var/log/grafana") || !contains(host.dirs, "HOME/.cache/zsh") {
		t.Errorf("host dirs missing merge: %v", host.dirs)
	}

	// vm: empty leaf -> exactly base.
	vm, err := s.resolveEffective("virt/mac-os-aarch64")
	if err != nil {
		t.Fatal(err)
	}
	if len(vm.install) != 1 || vm.install[0] != "ci/zsh/scripts/installs/mac/brew" {
		t.Errorf("vm install = %v, want base only", vm.install)
	}
	if contains(vm.dirs, "/var/log/grafana") {
		t.Errorf("vm must not inherit host dirs: %v", vm.dirs)
	}
}

func TestResolveEffectiveUndefinedFails(t *testing.T) {
	s := writeSpec(t)
	_, err := s.resolveEffective("virt/linux-aarch64") // declared, not defined
	if err == nil {
		t.Fatal("expected error for declared-but-undefined profile")
	}
}

func TestIncludeProfilesCycle(t *testing.T) {
	const cyclic = `
profiles:
  virt:
    mac-os-aarch64:
a:
  include-profiles: [b]
b:
  include-profiles: [a]
virt/mac-os-aarch64:
  include-profiles: [a]
`
	dir := t.TempDir()
	p := filepath.Join(dir, "che.yml")
	if err := os.WriteFile(p, []byte(cyclic), 0644); err != nil {
		t.Fatal(err)
	}
	s, err := loadSpec(p)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.resolveEffective("virt/mac-os-aarch64"); err == nil {
		t.Fatal("expected cycle error")
	}
}

func TestIncludeExcludeSections(t *testing.T) {
	const sp = `
profiles:
  virt:
    mac-os-aarch64:
base-cli:
  load-configuration:
    etc/zshrc:
    etc/zsh/**:
  install:
    - ci/zsh/scripts/installs/mac/brew
extra:
  load-configuration:
    HOME/.config/extra/**:
virt/mac-os-aarch64:
  include-profiles: [base-cli]
  include:
    profiles: [extra]
    load-configuration:
      - HOME/.config/oneoff/**
    install:
      - ci/zsh/scripts/installs/mac/oneoff
  exclude:
    load-configuration:
      - etc/zsh/**
    install:
      - ci/zsh/scripts/installs/mac/brew
`
	dir := t.TempDir()
	p := filepath.Join(dir, "che.yml")
	if err := os.WriteFile(p, []byte(sp), 0644); err != nil {
		t.Fatal(err)
	}
	s, err := loadSpec(p)
	if err != nil {
		t.Fatal(err)
	}
	eff, err := s.resolveEffective("virt/mac-os-aarch64")
	if err != nil {
		t.Fatal(err)
	}
	hasOp := func(pat string, inc bool) bool {
		for _, op := range eff.globOps {
			if op.pattern == pat && op.include == inc {
				return true
			}
		}
		return false
	}
	// include adds: extra profile's glob + the inline glob (as include ops)
	if !hasOp("HOME/.config/extra/**", true) {
		t.Errorf("include.profiles not merged: %v", eff.globOps)
	}
	if !hasOp("HOME/.config/oneoff/**", true) {
		t.Errorf("include.load-configuration not added: %v", eff.globOps)
	}
	if !slices.Contains(eff.install, "ci/zsh/scripts/installs/mac/oneoff") {
		t.Errorf("include.install not added: %v", eff.install)
	}
	// exclude.load-configuration recorded as an exclude op
	if !hasOp("etc/zsh/**", false) {
		t.Errorf("exclude.load-configuration not recorded: %v", eff.globOps)
	}
	// exclude.install subtracts exactly
	if slices.Contains(eff.install, "ci/zsh/scripts/installs/mac/brew") {
		t.Errorf("exclude.install not removed: %v", eff.install)
	}
	// untouched include survives
	if !hasOp("etc/zshrc", true) {
		t.Errorf("etc/zshrc include op missing: %v", eff.globOps)
	}
}

func TestIncludeProfilesUndefined(t *testing.T) {
	const bad = `
profiles:
  virt:
    mac-os-aarch64:
virt/mac-os-aarch64:
  include-profiles: [nonexistent]
`
	dir := t.TempDir()
	p := filepath.Join(dir, "che.yml")
	if err := os.WriteFile(p, []byte(bad), 0644); err != nil {
		t.Fatal(err)
	}
	s, err := loadSpec(p)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.resolveEffective("virt/mac-os-aarch64"); err == nil {
		t.Fatal("expected undefined-include error")
	}
}

func contains(xs []string, want string) bool {
	return slices.Contains(xs, want)
}

// [<] 🤖🤖🤖
