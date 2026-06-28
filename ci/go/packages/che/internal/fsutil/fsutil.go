package fsutil

// [>] 🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/go-git/go-git/v5"

	"configs/ci/go/packages/che/internal/log"
)

// FS runs mutating filesystem ops, honoring DryRun and escalating priv per-dest
// (sudo iff the dest is outside the invoking user's Home).
type FS struct {
	Home   string
	Root   string // repo root/ tree; repo-aware backups skip links into it
	DryRun bool
}

func (f FS) logMsg(title, msg string) { log.Msg(title, msg, f.DryRun) }

// Log emits a log line through the dry-run gate.
func (f FS) Log(title, msg string) { f.logMsg(title, msg) }

// UnderHome reports whether dest is the user-owned Home tree (no sudo needed).
func (f FS) UnderHome(dest string) bool {
	return dest == f.Home || strings.HasPrefix(dest, f.Home+"/")
}

// mutate logs (verb: logArg) then, unless dry-run, runs argv with per-dest priv
// escalation. Every mutating op funnels through here for one dry-run+log gate.
func (f FS) mutate(verb, logArg, dest string, argv ...string) error {
	if !f.DryRun {
		if err := f.Priv(dest, argv...); err != nil {
			return err
		}
	}
	f.logMsg(verb, logArg)
	return nil
}

// Mkdir makes a single dir with mode. asUser, when set under root, creates it owned
// by that user. parents adds -p.
func (f FS) Mkdir(dest, asUser string, mode os.FileMode, parents bool) error {
	if f.DryRun {
		f.logMsg("mkdir", dest)
		return nil
	}
	argv := f.MkdirArgv(dest, asUser, ModeArg(mode), parents)
	if err := run(exec.Command(argv[0], argv[1:]...)); err != nil {
		return err
	}
	f.logMsg("mkdir", dest)
	return nil
}

// MkdirArgv builds a mkdir command, escalating per the dest/asUser rules:
// asUser -> sudo -u <user> (create owned by the invoking user); root-tree -> sudo
// unless already root; HOME-tree -> direct. parents adds -p.
func (f FS) MkdirArgv(dest, asUser, mode string, parents bool) []string {
	base := []string{"mkdir"}
	if parents {
		base = append(base, "-p")
	}
	base = append(base, "-m", mode, dest)
	switch {
	case asUser != "" && os.Geteuid() == 0:
		return append([]string{"sudo", "-u", asUser}, base...)
	case !f.UnderHome(dest) && os.Geteuid() != 0:
		return append([]string{"sudo"}, base...)
	default:
		return base
	}
}

// Chmod applies an explicit mode arg (setgid/sticky bits not honored by mkdir mode).
func (f FS) Chmod(chmodArg, dest string) error {
	return f.mutate("chmod", chmodArg+" "+dest, dest, "chmod", chmodArg, dest)
}

func (f FS) Symlink(target, dest string) error {
	return f.mutate("ln", dest, dest, "ln", "-fhs", target, dest)
}

func (f FS) Copy(src, dest string, mode os.FileMode) error {
	return f.mutate("cp", dest, dest, "install", "-m", ModeArg(mode), src, dest)
}

func (f FS) Remove(dest string) error {
	return f.mutate("rm", dest, dest, "rm", "-f", dest)
}

func (f FS) Chown(owner, dest string) error {
	return f.mutate("chown", owner+" "+dest, dest, "chown", owner, dest)
}

// Install writes body to a temp then installs it at dest with mode/owner, escalating
// priv iff dest is outside Home. owner "" -> no -o/-g. Honors dry-run.
func (f FS) Install(dest string, body []byte, mode os.FileMode, owner string) error {
	if f.DryRun {
		f.logMsg("render", dest)
		return nil
	}
	tmp, err := os.CreateTemp("", "che-tmpl-*")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())
	if _, err := tmp.Write(body); err != nil {
		return err
	}
	tmp.Close()

	argv := []string{"install", "-m", ModeArg(mode)}
	if owner != "" {
		o, g, _ := strings.Cut(owner, ":")
		argv = append(argv, "-o", o, "-g", g)
	}
	argv = append(argv, tmp.Name(), dest)
	return f.mutate("render", dest, dest, argv...)
}

// Priv runs argv as root unless dest is under Home (user-owned).
func (f FS) Priv(dest string, argv ...string) error {
	if !f.UnderHome(dest) && os.Geteuid() != 0 {
		argv = append([]string{"sudo"}, argv...)
	}
	return run(exec.Command(argv[0], argv[1:]...))
}

// BackupBeforeOverwrite copies an existing dest -> dest.<ts>.bk before clobber.
// repoAware: skip symlinks already resolving into the repo root (links we made).
func (f FS) BackupBeforeOverwrite(dest string, repoAware bool) error {
	fi, err := os.Lstat(dest)
	if err != nil {
		return nil // nothing to preserve
	}
	if fi.Mode()&os.ModeSymlink != 0 {
		target, terr := os.Readlink(dest)
		if terr == nil {
			if _, serr := os.Stat(dest); serr != nil {
				return nil // broken link: nothing to preserve
			}
			if repoAware {
				abs := target
				if !filepath.IsAbs(abs) {
					abs = filepath.Join(filepath.Dir(dest), target)
				}
				if resolved, rerr := filepath.EvalSymlinks(abs); rerr == nil &&
					strings.HasPrefix(resolved, f.Root+"/") {
					return nil // a link we own
				}
			}
		}
	}
	bk := dest + "." + time.Now().Format("20060102T150405") + ".bk"
	return f.mutate("backup", bk, dest, "cp", "-p", dest, bk)
}

func run(c *exec.Cmd) error {
	c.Stdout, c.Stderr = os.Stdout, os.Stderr
	return c.Run()
}

// ModeArg renders an octal mode for install/mkdir/chmod argv.
func ModeArg(m os.FileMode) string { return fmt.Sprintf("%04o", m) }

// IsDir reports whether p is an existing directory.
func IsDir(p string) bool {
	fi, err := os.Stat(p)
	return err == nil && fi.IsDir()
}

// openRepo opens the git repo containing dir (walking up for .git) and returns it
// plus the worktree root.
func openRepo(dir string) (*git.Repository, string, error) {
	repo, err := git.PlainOpenWithOptions(dir, &git.PlainOpenOptions{DetectDotGit: true})
	if err != nil {
		return nil, "", fmt.Errorf("open git repo from %s: %w", dir, err)
	}
	wt, err := repo.Worktree()
	if err != nil {
		return nil, "", fmt.Errorf("worktree from %s: %w", dir, err)
	}
	root, err := filepath.EvalSymlinks(wt.Filesystem.Root())
	if err != nil {
		return nil, "", err
	}
	return repo, root, nil
}

// RepoRoot returns the git toplevel for dir (the repo working-tree root).
func RepoRoot(dir string) (string, error) {
	_, root, err := openRepo(dir)
	return root, err
}

// TrackedFiles lists git-tracked files under root, repo-relative to root. root may
// be a subtree of the repo; only entries within it are returned, prefix-stripped.
func TrackedFiles(root string) ([]string, error) {
	repo, repoRoot, err := openRepo(root)
	if err != nil {
		return nil, err
	}
	idx, err := repo.Storer.Index()
	if err != nil {
		return nil, fmt.Errorf("read git index under %s: %w", root, err)
	}
	root, err = filepath.EvalSymlinks(root)
	if err != nil {
		return nil, err
	}
	var files []string
	for _, e := range idx.Entries {
		abs := filepath.Join(repoRoot, e.Name)
		rel, err := filepath.Rel(root, abs)
		if err != nil || rel == ".." || strings.HasPrefix(rel, "../") {
			continue // outside the requested subtree
		}
		files = append(files, rel)
	}
	return files, nil
}

// [<] 🤖🤖
