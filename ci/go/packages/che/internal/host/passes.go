package host

// [>] 🤖🤖

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"configs/ci/go/packages/che/internal/fsutil"
	"configs/ci/go/packages/che/internal/spec"
)

// Bin is che's binary name, carried in per-run backup archive filenames.
const Bin = "che"

// archiveBefore snapshots every existing dest into one per-run .tar.bz2 under
// the XDG backups dir before a mutating pass runs (sub = pass identity).
func (h Host) archiveBefore(sub string, dests []string) error {
	ts := time.Now().Format(fsutil.TsLayout)
	path := fsutil.BackupArchivePath(h.Home, Bin, sub, ts)
	return h.fs.ArchiveDests(path, dests)
}

// MkDirs creates repo-tree ancestor dirs (parents first) plus profile extra-dirs.
func (h Host) MkDirs(dirRels []string, extraDirs []spec.FileItem) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	for _, item := range extraDirs {
		rel := item.Dests[0].Path
		dest := h.ToDest(rel)
		if fsutil.IsDir(dest) {
			continue
		}
		if err := h.mkExtraDir(item, dest); err != nil {
			return err
		}
	}
	return nil
}

// ensureConfigDirs creates repo-tree ancestor dirs (parents first), no spec
// perms: mode 0 -> mkdir honors umask. Idempotent.
func (h Host) ensureConfigDirs(dirRels []string) error {
	for _, rel := range dirRels {
		dest := h.ToDest(rel)
		if fsutil.IsDir(dest) {
			continue
		}
		if err := h.fs.Mkdir(dest, "", 0, false); err != nil {
			return err
		}
	}
	return nil
}

// mkExtraDir creates one extra-dir with -p. Mode/owner from spec when set, else
// mkdir runs with no -m (umask). A chmod with set-bits (>0777) reapplied via
// chmod so the special bits stick.
func (h Host) mkExtraDir(item spec.FileItem, dest string) error {
	var mode os.FileMode
	asUser := ""
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

// MkLinks symlinks each config into its live dest (ln -fhs), archiving existing
// dests upfront, skipping links already pointing into the repo.
func (h Host) MkLinks(links []spec.FileItem, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	dests := make([]string, len(links))
	for i, item := range links {
		dests[i] = h.ToDest(item.Rel)
	}
	if err := h.archiveBefore("link", dests); err != nil {
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
		if err := h.fs.Symlink(src, dest); err != nil {
			return err
		}
	}
	return nil
}

// MkCopies copies each *.host.cp to its dest(s) (marker stripped, or explicit
// dest) when contents differ, archiving existing dests upfront, applying spec
// perms (else default).
func (h Host) MkCopies(copies []spec.FileItem, dirRels []string) error {
	if err := h.ensureConfigDirs(dirRels); err != nil {
		return err
	}
	var dests []string
	for _, item := range copies {
		dests = append(dests, h.copyDests(item)...)
	}
	if err := h.archiveBefore("copy", dests); err != nil {
		return err
	}
	for _, item := range copies {
		src := h.Src(item.Rel)
		for _, dest := range h.copyDests(item) {
			if sameContent(src, dest) {
				continue
			}
			mode, _ := parseMode(item.Chmod)
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

// PruneBrokenLinks removes broken symlinks in config-set dirs (live dests).
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
			p := filepath.Join(dest, e.Name())
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
