package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// install-tools: dry-run logs each unit's abs path, no exec.
func TestInstallCmd(t *testing.T) {
	setupDryRun(t)
	out := testutil.RunDry(t, InstallCmd, true)
	testutil.WantLines(t, out, "install: "+theHost.RepoRoot+"/install/unit [dry-run]")
}

// [<] 🤖🤖
