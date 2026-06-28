package main

// [>] 🤖🤖🤖

import (
	"path/filepath"
)

// passLink symlinks each config file into its live dest (ln -fhs), backing up any
// non-repo dest first and skipping links that already point into the repo.
// Ports the link pass of upsert-configs.
func (a *app) passLink() error {
	cs, err := a.resolveConfigs()
	if err != nil {
		return err
	}
	for _, rel := range cs.links {
		src := filepath.Join(a.root, rel)
		dest := a.toDest(rel)
		// skip if dest already resolves to this exact source (idempotent).
		if resolved, rerr := filepath.EvalSymlinks(dest); rerr == nil {
			if srcResolved, serr := filepath.EvalSymlinks(src); serr == nil && resolved == srcResolved {
				continue
			}
		}
		if err := a.backupBeforeOverwrite(dest, true); err != nil {
			return err
		}
		if err := a.symlink(src, dest); err != nil {
			return err
		}
	}
	return nil
}

// [<] 🤖🤖🤖
