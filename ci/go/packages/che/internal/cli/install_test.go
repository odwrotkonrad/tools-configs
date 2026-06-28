package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// install-tools: runs the profile's install units; in dry-run it logs each unit's
// absolute path without executing it.
func TestInstallCmd(t *testing.T) {
	testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, InstallCmd, true)
	testutil.WantLines(t, out, "install: "+theHost.RepoRoot+"/install/unit [dry-run]")
}

// [<] 🤖🤖
