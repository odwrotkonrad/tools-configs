package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// prune-links: logs the root it scans for broken symlinks (nothing to remove in the
// fresh fixture).
func TestPruneCmd(t *testing.T) {
	testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, PruneCmd, true)
	testutil.WantLines(t, out, "prune-links: "+theHost.Root+" [dry-run]")
}

// [<] 🤖🤖
