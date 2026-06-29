package host

// [>] 🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"

	"configs/ci/go/packages/che/internal/fsutil"
)

// Host is the live system the load passes act on: repo source tree, invoking
// identity, detected profile, mutating filesystem.
type Host struct {
	RepoRoot string // <configs> dir (contains che.yml, ci/, templates/)
	Root     string // <configs>/root, the load passes' source subtree
	Home     string
	Profile  string // "<space>/<os>-<arch>"
	DryRun   bool
	fs       fsutil.FS
}

// New builds a Host, wiring an fsutil.FS that honors dryRun, escalates priv per-dest.
func New(repoRoot, home, profile string, dryRun bool) Host {
	root := filepath.Join(repoRoot, "root")
	return Host{
		RepoRoot: repoRoot,
		Root:     root,
		Home:     home,
		Profile:  profile,
		DryRun:   dryRun,
		fs:       fsutil.FS{Home: home, DryRun: dryRun},
	}
}

// Src maps a repo-relative path (under root/) to its absolute source path.
func (h Host) Src(rel string) string { return filepath.Join(h.Root, rel) }

// TrackedFiles lists git-tracked files under root/, repo-relative to root.
func (h Host) TrackedFiles() ([]string, error) { return fsutil.TrackedFiles(h.Root) }

// ResolveInstall expands the install list IN SPEC ORDER (no sort). Each entry must
// resolve to >=1 script ([why] catches typos/renames). Globs expand in place.
func (h Host) ResolveInstall(installs []string) ([]string, error) {
	var out []string
	for _, entry := range installs {
		abs := filepath.Join(h.RepoRoot, entry)
		if strings.ContainsAny(entry, "*?[") {
			hits, err := filepath.Glob(abs)
			if err != nil {
				return nil, err
			}
			if len(hits) == 0 {
				return nil, fmt.Errorf("install entry matched no script: %s", entry)
			}
			slices.Sort(hits)
			out = append(out, hits...)
			continue
		}
		if _, err := os.Stat(abs); err != nil {
			return nil, fmt.Errorf("install script not found: %s", entry)
		}
		out = append(out, abs)
	}
	return out, nil
}

// ToDest maps a repo-relative path (under root/) to its live dest:
// HOME or HOME/<rest> -> $HOME[/<rest>], else /<rest>.
func (h Host) ToDest(rel string) string {
	if rel == "HOME" {
		return h.Home
	}
	if rest, ok := strings.CutPrefix(rel, "HOME/"); ok {
		return filepath.Join(h.Home, rest)
	}
	if strings.HasPrefix(rel, "/") {
		return rel // already a live absolute path (make-extra-dirs entries)
	}
	return "/" + rel
}

// UnderHome reports whether dest is the user-owned $HOME tree (no sudo needed).
func (h Host) UnderHome(dest string) bool { return h.fs.UnderHome(dest) }

// InvokingUser: root runs the passes; HOME-tree dirs belong to the invoking user.
func (h Host) InvokingUser() string {
	if u := os.Getenv("SUDO_USER"); u != "" {
		return u
	}
	if out, err := exec.Command("stat", "-f", "%Su", h.Home).Output(); err == nil {
		return strings.TrimSpace(string(out))
	}
	return ""
}

// [<] 🤖🤖
