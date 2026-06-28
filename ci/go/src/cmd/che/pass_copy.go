package main

// [>] 🤖🤖🤖

import (
	"os"
	"path/filepath"
	"strings"
)

// copyPerms: copied dests with explicit owner:perms. Sole source of owner/perms;
// root-owned launchd daemons must be root:wheel 0644. Keyed by dest path; only
// fires for dests actually loaded, so the VM (which never loads these) skips them.
var copyServices = []string{
	"dir-size-exporter", "grafana", "jaeger", "loki",
	"otelcol", "port-exporter", "prometheus",
}

func (a *app) copyPerms(dest string) (owner string, mode os.FileMode, ok bool) {
	for _, s := range copyServices {
		if dest == "/Library/LaunchDaemons/d-root-"+s+".plist" {
			return "root:wheel", 0644, true
		}
	}
	return "", 0, false
}

// passCopy copies each *.host.auto.cp to its live dest (marker stripped), only
// when contents differ; backs up first; applies the perms map. Ports the copy pass.
func (a *app) passCopy() error {
	cs, err := a.resolveConfigs()
	if err != nil {
		return err
	}
	if err := a.ensureConfigDirs(cs); err != nil {
		return err
	}
	for _, rel := range cs.copies {
		src := filepath.Join(a.root, rel)
		destRel := strings.TrimSuffix(rel, cpExt)
		dest := a.toDest(destRel)
		if sameContent(src, dest) {
			continue
		}
		if err := a.backupBeforeOverwrite(dest, false); err != nil {
			return err
		}
		owner, mode, custom := a.copyPerms(dest)
		if !custom {
			mode = 0644
			if strings.HasPrefix(destRel, "HOME/") {
				mode = 0640
			}
		}
		if err := a.copy(src, dest, mode); err != nil {
			return err
		}
		if custom {
			if err := a.chown(owner, dest); err != nil {
				return err
			}
		}
	}
	return nil
}

func sameContent(a, b string) bool {
	x, err := os.ReadFile(a)
	if err != nil {
		return false
	}
	y, err := os.ReadFile(b)
	if err != nil {
		return false
	}
	return string(x) == string(y)
}

// [<] 🤖🤖🤖
