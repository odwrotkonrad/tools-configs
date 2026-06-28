package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// passInstall runs the profile's install units in spec-list order. Each unit runs
// with the repo's FPATH/PATH (so fn-is-os/fn-is-arch/fn-install-if-missing autoload) and
// CONFIGS_PROFILE/CONFIGS_SPACE exported (so a unit picks the right Brewfile
// section). Fatal on the first non-zero exit. Replaces host-install-all.
func (a *app) passInstall() error {
	scripts, err := a.resolveInstall()
	if err != nil {
		return err
	}
	env := a.installEnv()
	for _, script := range scripts {
		if a.dryRun {
			a.logMsg("install", script)
			continue
		}
		a.logMsg("install", script)
		c := exec.Command(script)
		c.Env = env
		c.Stdout, c.Stderr = os.Stdout, os.Stderr
		if err := c.Run(); err != nil {
			return fmt.Errorf("install unit failed: %s: %w", script, err)
		}
	}
	return nil
}

// installEnv mirrors the Makefile $(ZSH) wrapper env + che's profile exports.
func (a *app) installEnv() []string {
	fns := filepath.Join(a.repoRoot, "ci/zsh/functions")
	scripts := filepath.Join(a.repoRoot, "ci/zsh/scripts")
	installs := filepath.Join(scripts, "installs")

	env := os.Environ()
	env = prepend(env, "FPATH", fns)
	env = prepend(env, "PATH", fns+":"+scripts+":"+installs)
	env = append(env,
		"CONFIGS_PROFILE="+a.profile,
		"CONFIGS_SPACE="+a.space,
	)
	return env
}

// prepend sets key=value:<existing> in a copy of env.
func prepend(env []string, key, value string) []string {
	prefix := key + "="
	out := make([]string, 0, len(env)+1)
	found := false
	for _, kv := range env {
		if len(kv) >= len(prefix) && kv[:len(prefix)] == prefix {
			out = append(out, prefix+value+":"+kv[len(prefix):])
			found = true
		} else {
			out = append(out, kv)
		}
	}
	if !found {
		out = append(out, prefix+value)
	}
	return out
}

// [<] 🤖🤖🤖
