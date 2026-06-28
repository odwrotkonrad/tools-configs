package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"time"
)

// app carries the resolved profile, spec, effective set, and the dry-run gate.
type app struct {
	repoRoot string // <configs> dir (contains root/, che.yml, ci/)
	root     string // <configs>/root
	home     string
	profile  string
	space    string // bare-metal | virt
	spec     *spec
	eff      effective
	dryRun   bool
}

func newApp(dryRun bool) (*app, error) {
	home, err := invokingHome()
	if err != nil {
		return nil, err
	}
	sp, err := specPath()
	if err != nil {
		return nil, err
	}
	repoRoot := filepath.Dir(sp)
	s, err := loadSpec(sp)
	if err != nil {
		return nil, err
	}
	profile := detectProfile()
	if forced := os.Getenv("CHE_FORCE_PROFILE"); forced != "" {
		profile = forced // test hook (verification #3)
	}
	eff, err := s.resolveEffective(profile)
	if err != nil {
		return nil, err
	}
	return &app{
		repoRoot: repoRoot,
		root:     filepath.Join(repoRoot, "root"),
		home:     home,
		profile:  profile,
		space:    strings.SplitN(profile, "/", 2)[0],
		spec:     s,
		eff:      eff,
		dryRun:   dryRun,
	}, nil
}

// invokingHome resolves the invoking user's home. Running as root via sudo
// (EUID 0, SUDO_USER set), it looks up that user's home from passwd so dest paths
// derive from the real user, not /var/root. Otherwise it uses $HOME.
func invokingHome() (string, error) {
	if os.Geteuid() == 0 {
		if name := os.Getenv("SUDO_USER"); name != "" {
			u, err := user.Lookup(name)
			if err != nil {
				return "", fmt.Errorf("lookup SUDO_USER %q: %w", name, err)
			}
			return u.HomeDir, nil
		}
	}
	home := os.Getenv("HOME")
	if home == "" {
		return "", fmt.Errorf("HOME must be set")
	}
	return home, nil
}

// toDest maps a repo-relative path (under root/) to its live dest:
// HOME or HOME/<rest> -> $HOME[/<rest>], else /<rest>.
func (a *app) toDest(rel string) string {
	if rel == "HOME" {
		return a.home
	}
	if rest, ok := strings.CutPrefix(rel, "HOME/"); ok {
		return filepath.Join(a.home, rest)
	}
	if strings.HasPrefix(rel, "/") {
		return rel // already a live absolute path (make-extra-dirs entries)
	}
	return "/" + rel
}

// underHome reports whether dest is the user-owned $HOME tree (no sudo needed).
func (a *app) underHome(dest string) bool {
	return dest == a.home || strings.HasPrefix(dest, a.home+"/")
}

// ----- mutating helpers; honor dryRun and escalate priv per-dest -----

func (a *app) mkdir(dest string, asUser string, mode os.FileMode) error {
	if a.dryRun {
		a.logMsg("mkdir", dest)
		return nil
	}
	argv := a.mkdirArgv(dest, asUser, fmt.Sprintf("%04o", mode), false)
	if err := run(exec.Command(argv[0], argv[1:]...)); err != nil {
		return err
	}
	a.logMsg("mkdir", dest)
	return nil
}

// mkdirArgv builds a mkdir command, escalating per the dest/asUser rules:
// asUser -> sudo -u <user> (create owned by the invoking user); root-tree -> sudo
// unless already root; HOME-tree -> direct. parents adds -p.
func (a *app) mkdirArgv(dest, asUser, mode string, parents bool) []string {
	base := []string{"mkdir"}
	if parents {
		base = append(base, "-p")
	}
	base = append(base, "-m", mode, dest)
	switch {
	case asUser != "" && os.Geteuid() == 0:
		// root makes HOME-tree dirs as the invoking user (owned at birth)
		return append([]string{"sudo", "-u", asUser}, base...)
	case !a.underHome(dest) && os.Geteuid() != 0:
		return append([]string{"sudo"}, base...)
	default:
		return base
	}
}

func (a *app) symlink(target, dest string) error {
	if a.dryRun {
		a.logMsg("ln", dest)
		return nil
	}
	if err := a.priv(dest, "ln", "-fhs", target, dest); err != nil {
		return err
	}
	a.logMsg("ln", dest)
	return nil
}

func (a *app) copy(src, dest string, mode os.FileMode) error {
	if a.dryRun {
		a.logMsg("cp", dest)
		return nil
	}
	if err := a.priv(dest, "install", "-m", fmt.Sprintf("%04o", mode), src, dest); err != nil {
		return err
	}
	a.logMsg("cp", dest)
	return nil
}

func (a *app) remove(dest string) error {
	if a.dryRun {
		a.logMsg("rm", dest)
		return nil
	}
	if err := a.priv(dest, "rm", "-f", dest); err != nil {
		return err
	}
	a.logMsg("rm", dest)
	return nil
}

func (a *app) chown(owner, dest string) error {
	if a.dryRun {
		a.logMsg("chown", owner+" "+dest)
		return nil
	}
	if err := a.priv(dest, "chown", owner, dest); err != nil {
		return err
	}
	a.logMsg("chown", owner+" "+dest)
	return nil
}

// priv runs argv as root unless dest is under $HOME (user-owned).
func (a *app) priv(dest string, argv ...string) error {
	if !a.underHome(dest) && os.Geteuid() != 0 {
		argv = append([]string{"sudo"}, argv...)
	}
	return run(exec.Command(argv[0], argv[1:]...))
}

// backupBeforeOverwrite copies an existing dest -> dest.<ts>.bk before clobber.
// repoAware: skip symlinks already resolving into the repo root (links we made).
func (a *app) backupBeforeOverwrite(dest string, repoAware bool) error {
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
					strings.HasPrefix(resolved, a.root+"/") {
					return nil // a link we own
				}
			}
		}
	}
	ts := time.Now().Format("20060102T150405")
	bk := dest + "." + ts + ".bk"
	if a.dryRun {
		a.logMsg("backup", bk)
		return nil
	}
	if err := a.priv(dest, "cp", "-p", dest, bk); err != nil {
		return err
	}
	a.logMsg("backup", bk)
	return nil
}

// logMsg prints 'HH:MM:SS.mmm: <title>: <msg>' to match the zsh log-msg format.
func (a *app) logMsg(title, msg string) {
	now := time.Now()
	stamp := now.Format("15:04:05") + "." + fmt.Sprintf("%03d", now.Nanosecond()/1e6)
	if a.dryRun {
		fmt.Printf("%s: %s: %s [dry-run]\n", stamp, title, msg)
		return
	}
	fmt.Printf("%s: %s: %s\n", stamp, title, msg)
}

func run(c *exec.Cmd) error {
	c.Stdout, c.Stderr = os.Stdout, os.Stderr
	return c.Run()
}

// [<] 🤖🤖🤖
