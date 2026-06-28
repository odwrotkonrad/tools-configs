package host

// [>] 🤖🤖

import (
	"os"
	"path/filepath"
	"strings"

	"configs/ci/go/packages/che/internal/fsutil"
	"configs/ci/go/packages/che/internal/spec"
)

// MkDirs creates repo-tree ancestor dirs (parents first) plus profile extra-dirs.
func (h Host) MkDirs(dirRels, extraDirs []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	user := h.InvokingUser()
	for _, entry := range extraDirs {
		dest := h.ToDest(entry)
		if fsutil.IsDir(dest) {
			continue
		}
		if err := h.mkExtraDir(entry, dest, user); err != nil {
			return err
		}
	}
	return nil
}

// ensureConfigDirs creates repo-tree ancestor dirs (parents first): HOME-tree user 0750, root-tree 0755. Idempotent.
func (h Host) ensureConfigDirs(dirRels []string) error {
	user := h.InvokingUser()
	for _, rel := range dirRels {
		dest := h.ToDest(rel)
		if fsutil.IsDir(dest) {
			continue
		}
		asUser, mode := "", os.FileMode(0755)
		if isHome(rel) {
			asUser, mode = user, 0750
		}
		if err := h.fs.Mkdir(dest, asUser, mode, false); err != nil {
			return err
		}
	}
	return nil
}

// isHome reports whether a repo-relative path is in HOME tree.
func isHome(rel string) bool { return rel == "HOME" || strings.HasPrefix(rel, "HOME/") }

// mkExtraDir creates one extra-dir with -p, then applies special owner/mode classes.
func (h Host) mkExtraDir(rel, dest, user string) error {
	switch {
	case isHome(rel):
		return h.fs.Mkdir(dest, user, 0750, true)
	case strings.HasPrefix(rel, "var/log/") ||
		strings.HasPrefix(rel, "usr/local/var") ||
		rel == "var/custom/cache/dir_size_exporter":
		if err := h.fs.Mkdir(dest, "", 02775, true); err != nil { // custom group + setgid
			return err
		}
		return h.fs.Chmod("2775", dest)
	default:
		return h.fs.Mkdir(dest, "", 0755, true)
	}
}

// MkLinks symlinks each config into its live dest (ln -fhs), backing up non-repo dests, skipping links already pointing into the repo.
func (h Host) MkLinks(links, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	for _, rel := range links {
		src := h.Src(rel)
		dest := h.ToDest(rel)
		if resolved, rerr := filepath.EvalSymlinks(dest); rerr == nil {
			if srcResolved, serr := filepath.EvalSymlinks(src); serr == nil && resolved == srcResolved {
				continue
			}
		}
		if err := h.fs.BackupBeforeOverwrite(dest, true); err != nil {
			return err
		}
		if err := h.fs.Symlink(src, dest); err != nil {
			return err
		}
	}
	return nil
}

// copyServices: copied dests with explicit owner:perms. [why] root launchd daemons must be root:wheel 0644. Only loaded dests, so the VM skips them.
var copyServices = []string{
	"dir-size-exporter", "grafana", "jaeger", "loki",
	"otelcol", "port-exporter", "prometheus",
}

func copyPerms(dest string) (owner string, mode os.FileMode, ok bool) {
	for _, s := range copyServices {
		if dest == "/Library/LaunchDaemons/"+s+".plist" {
			return "root:wheel", 0644, true
		}
	}
	return "", 0, false
}

// MkCopies copies each *.host.cp to its live dest (marker stripped) when contents differ, backing up first, applying the perms map.
func (h Host) MkCopies(copies, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	for _, rel := range copies {
		src := h.Src(rel)
		destRel := strings.TrimSuffix(rel, spec.CpExt)
		dest := h.ToDest(destRel)
		if sameContent(src, dest) {
			continue
		}
		if err := h.fs.BackupBeforeOverwrite(dest, false); err != nil {
			return err
		}
		owner, mode, custom := copyPerms(dest)
		if !custom {
			mode = 0644
			if strings.HasPrefix(destRel, "HOME/") {
				mode = 0640
			}
		}
		if err := h.fs.Copy(src, dest, mode); err != nil {
			return err
		}
		if custom {
			if err := h.fs.Chown(owner, dest); err != nil {
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

// PruneBrokenLinks removes broken symlinks in config-set dirs (live dests), skipping *.bk backups.
func (h Host) PruneBrokenLinks(dirRels []string) error {
	h.fs.Log("prune-links", h.Root)
	seen := map[string]bool{}
	for _, rel := range dirRels {
		dest := h.ToDest(rel)
		if seen[dest] {
			continue
		}
		seen[dest] = true
		entries, derr := os.ReadDir(dest)
		if derr != nil {
			continue // [why] dir may not exist on host yet
		}
		for _, e := range entries {
			name := e.Name()
			if strings.HasSuffix(name, ".bk") {
				continue
			}
			p := filepath.Join(dest, name)
			fi, lerr := os.Lstat(p)
			if lerr != nil || fi.Mode()&os.ModeSymlink == 0 {
				continue
			}
			if _, serr := os.Stat(p); serr != nil { // [what] broken: target gone
				if err := h.fs.Remove(p); err != nil {
					return err
				}
			}
		}
	}
	return nil
}

// [<] 🤖🤖
