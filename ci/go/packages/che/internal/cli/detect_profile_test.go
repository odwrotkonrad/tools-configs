package cli

// [>] 🤖🤖

import (
	"strings"
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// detect prints exactly the resolved profile, no dry-run lines.
func TestDetectCmd(t *testing.T) {
	testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, DetectCmd, false)
	if got := strings.TrimSpace(out); got != testutil.CheProfile {
		t.Errorf("detect = %q, want %q", got, testutil.CheProfile)
	}
}

// [<] 🤖🤖
