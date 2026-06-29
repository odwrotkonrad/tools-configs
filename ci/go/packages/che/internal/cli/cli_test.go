package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// setupDryRun wires the mock che repo, flips dry-run on (reset on cleanup), and
// runs build() so each command test starts from resolved state. Returns HOME.
func setupDryRun(t *testing.T) string {
	t.Helper()
	home := testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}
	return home
}

// [<] 🤖🤖
