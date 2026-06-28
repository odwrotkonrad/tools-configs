package main

// [>] 🤖🤖🤖

import (
	"os"
	"path/filepath"
	"strings"
)

// passPrune removes broken symlinks within the dirs of the effective config set
// (live dests), skipping our *.bk backups. Ports delete-broken-links, scoping the
// search to the profile's dirs instead of the last-10-commits dir set.
func (a *app) passPrune() error {
	cs, err := a.resolveConfigs()
	if err != nil {
		return err
	}
	a.logMsg("prune-links", a.root)
	seen := map[string]bool{}
	for _, rel := range cs.dirs {
		dest := a.toDest(rel)
		if seen[dest] {
			continue
		}
		seen[dest] = true
		entries, derr := os.ReadDir(dest)
		if derr != nil {
			continue // dir may not exist on host yet
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
			if _, serr := os.Stat(p); serr != nil { // broken: target gone
				if err := a.remove(p); err != nil {
					return err
				}
			}
		}
	}
	return nil
}

// [<] 🤖🤖🤖
