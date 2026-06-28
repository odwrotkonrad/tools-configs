package host

// [>] 🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Install runs profile install units in spec order.
func (h Host) Install(scripts []string) error {
	env := h.installEnv()
	for _, script := range scripts {
		h.fs.Log("install", script)
		if h.DryRun {
			continue
		}
		c := exec.Command(script)
		c.Env = env
		c.Stdout, c.Stderr = os.Stdout, os.Stderr
		if err := c.Run(); err != nil {
			return fmt.Errorf("install unit failed: %s: %w", script, err)
		}
	}
	return nil
}

// installEnv mirrors Makefile $(ZSH) wrapper env, che profile exports.
func (h Host) installEnv() []string {
	fns := filepath.Join(h.RepoRoot, "ci/zsh/functions")
	scripts := filepath.Join(h.RepoRoot, "ci/zsh/scripts")
	installs := filepath.Join(scripts, "installs")

	env := os.Environ()
	env = prepend(env, "FPATH", fns)
	env = prepend(env, "PATH", fns+":"+scripts+":"+installs)
	env = append(env, "CONFIGS_PROFILE="+h.Profile)
	return env
}

// prepend sets key=value:<existing> in env copy.
func prepend(env []string, key, value string) []string {
	prefix := key + "="
	out := make([]string, 0, len(env)+1)
	found := false
	for _, kv := range env {
		if rest, ok := strings.CutPrefix(kv, prefix); ok {
			out = append(out, prefix+value+":"+rest)
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

// [<] 🤖🤖
