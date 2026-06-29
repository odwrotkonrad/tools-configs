package host

// [>] 🤖🤖

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"configs/ci/go/packages/che/internal/fsutil"
	"configs/ci/go/packages/che/internal/spec"
)

// MkDirs creates repo-tree ancestor dirs (parents first) plus profile extra-dirs.
func (h Host) MkDirs(dirRels []string, extraDirs []spec.FileItem) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	user := h.InvokingUser()
	for _, item := range extraDirs {
		rel := item.Dests[0].Path
		dest := h.ToDest(rel)
		if fsutil.IsDir(dest) {
			continue
		}
		if err := h.mkExtraDir(item, rel, dest, user); err != nil {
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

// mkExtraDir creates one extra-dir with -p, perms from spec else defaults
// (HOME-tree user 0750, else 0755). Owner/group from spec when set; a chmod
// with set-bits (>0777) reapplied via chmod so the special bits stick.
func (h Host) mkExtraDir(item spec.FileItem, rel, dest, user string) error {
	asUser, mode := dirDefault(rel, user)
	if m, ok := parseMode(item.Chmod); ok {
		mode = m
	}
	owner := ownerSpec(item)
	if owner != "" {
		asUser = "" // explicit owner applied via chown below, not mkdir -u
	}
	if err := h.fs.Mkdir(dest, asUser, mode, true); err != nil {
		return err
	}
	if mode > 0777 { // set-uid/gid/sticky: mkdir -m may drop it, reapply
		if err := h.fs.Chmod(fsutil.ModeArg(mode), dest); err != nil {
			return err
		}
	}
	if owner != "" {
		return h.fs.Chown(owner, dest)
	}
	return nil
}

// dirDefault returns the default (owner, mode) for an extra-dir by tree.
func dirDefault(rel, user string) (string, os.FileMode) {
	if isHome(rel) {
		return user, 0750
	}
	return "", 0755
}

// MkLinks symlinks each config into its live dest (ln -fhs), backing up non-repo dests, skipping links already pointing into the repo.
func (h Host) MkLinks(links []spec.FileItem, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	for _, item := range links {
		rel := item.Rel
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

// MkCopies copies each *.host.cp to its dest(s) (marker stripped, or explicit
// dest) when contents differ, backing up first, applying spec perms (else default).
func (h Host) MkCopies(copies []spec.FileItem, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	for _, item := range copies {
		src := h.Src(item.Rel)
		for _, dest := range h.copyDests(item) {
			if sameContent(src, dest) {
				continue
			}
			if err := h.fs.BackupBeforeOverwrite(dest, false); err != nil {
				return err
			}
			mode := copyMode(item)
			if err := h.fs.Copy(src, dest, mode); err != nil {
				return err
			}
			if owner := ownerSpec(item); owner != "" {
				if err := h.fs.Chown(owner, dest); err != nil {
					return err
				}
			}
		}
	}
	return nil
}

// copyDests returns the explicit dests (~/ resolved), else the marker-stripped derived dest.
func (h Host) copyDests(item spec.FileItem) []string {
	if len(item.Dests) == 0 {
		return []string{h.ToDest(strings.TrimSuffix(item.Rel, spec.CpExt))}
	}
	out := make([]string, len(item.Dests))
	for i, d := range item.Dests {
		out[i] = h.expandHome(d.Path)
	}
	return out
}

// copyMode: spec chmod when set, else default (0644, 0640 under HOME/).
func copyMode(item spec.FileItem) os.FileMode {
	if m, ok := parseMode(item.Chmod); ok {
		return m
	}
	if strings.HasPrefix(item.Rel, "HOME/") {
		return 0640
	}
	return 0644
}

// ownerSpec combines owner + owner-group into "owner:group" for fs.Chown ("" -> no chown).
func ownerSpec(item spec.FileItem) string {
	switch {
	case item.Owner != "" && item.OwnerGroup != "":
		return item.Owner + ":" + item.OwnerGroup
	case item.Owner != "":
		return item.Owner
	default:
		return ""
	}
}

// parseMode parses an octal chmod string ("" -> not set).
func parseMode(s string) (os.FileMode, bool) {
	if s == "" {
		return 0, false
	}
	n, err := strconv.ParseUint(s, 8, 32)
	if err != nil {
		return 0, false
	}
	return os.FileMode(n), true
}

// expandHome resolves a leading ~/ to the host home.
func (h Host) expandHome(p string) string {
	if rest, ok := strings.CutPrefix(p, "~/"); ok {
		return filepath.Join(h.Home, rest)
	}
	return p
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
