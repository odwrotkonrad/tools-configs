package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// ensureConfigDirs creates every repo-tree ancestor dir for the resolved config
// set (parents first), HOME-tree as the user umask 027 (0750), root-tree umask 022
// (0755). Idempotent (skips existing). Called by mk-dirs and before link/copy so a
// pass never fails on a missing parent dir.
func (a *app) ensureConfigDirs(cs configSet) error {
	user := a.invokingUser()
	for _, rel := range cs.dirs {
		dest := a.toDest(rel)
		if isDir(dest) {
			continue
		}
		if strings.HasPrefix(rel, "HOME/") || rel == "HOME" {
			if err := a.mkdir(dest, user, 0750); err != nil {
				return err
			}
		} else {
			if err := a.mkdir(dest, "", 0755); err != nil {
				return err
			}
		}
	}
	return nil
}

// passDirs creates every repo-tree dir (parents first) plus the profile's
// also-create-dirs. Ports mk-dirs + the dir half of upsert-configs.
func (a *app) passDirs() error {
	cs, err := a.resolveConfigs()
	if err != nil {
		return err
	}
	if err := a.ensureConfigDirs(cs); err != nil {
		return err
	}
	user := a.invokingUser()

	// also-create-dirs: not in the repo tree. HOME-tree user-owned 0750; system dirs
	// carry the special groups from mk-dirs (setgid 2775 / sticky 1777).
	for _, entry := range a.eff.dirs {
		dest := a.toDest(entry)
		if isDir(dest) {
			continue
		}
		if err := a.mkAlsoDir(entry, dest, user); err != nil {
			return err
		}
	}
	return nil
}

// mkAlsoDir creates one also-create-dir with -p (ancestors may be absent), then
// applies the special owner/mode classes from mk-dirs.
func (a *app) mkAlsoDir(rel, dest, user string) error {
	switch {
	case strings.HasPrefix(rel, "HOME/") || rel == "HOME":
		return a.mkdirP(dest, user, 0750, "")
	case strings.HasPrefix(rel, "var/log/") ||
		strings.HasPrefix(rel, "usr/local/var") ||
		rel == "var/custom/cache/dir_size_exporter":
		return a.mkdirP(dest, "", 02775, "2775") // custom group + setgid
	default:
		return a.mkdirP(dest, "", 0755, "")
	}
}

// mkdirP makes dest and ancestors; chmodArg (if set) is applied after, since
// setgid/sticky bits are not honored by mkdir mode under umask.
func (a *app) mkdirP(dest, asUser string, mode os.FileMode, chmodArg string) error {
	if a.dryRun {
		a.logMsg("mkdir", dest)
		if chmodArg != "" {
			a.logMsg("chmod", chmodArg+" "+dest)
		}
		return nil
	}
	argv := a.mkdirArgv(dest, asUser, modeArg(mode), true)
	if err := run(exec.Command(argv[0], argv[1:]...)); err != nil {
		return err
	}
	a.logMsg("mkdir", dest)
	if chmodArg != "" {
		if err := a.priv(dest, "chmod", chmodArg, dest); err != nil {
			return err
		}
		a.logMsg("chmod", chmodArg+" "+dest)
	}
	return nil
}

// invokingUser: root runs the passes; HOME-tree dirs belong to the invoking user.
func (a *app) invokingUser() string {
	if u := os.Getenv("SUDO_USER"); u != "" {
		return u
	}
	if out, err := exec.Command("stat", "-f", "%Su", a.home).Output(); err == nil {
		return strings.TrimSpace(string(out))
	}
	return ""
}

func isDir(p string) bool {
	fi, err := os.Stat(p)
	return err == nil && fi.IsDir()
}

func modeArg(m os.FileMode) string {
	return fmt.Sprintf("%04o", m)
}

// [<] 🤖🤖🤖
