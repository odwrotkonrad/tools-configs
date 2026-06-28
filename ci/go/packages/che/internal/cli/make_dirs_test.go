package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// mk-dirs: repo-tree config dirs plus profile extra-dir, under $HOME.
func TestDirsCmd(t *testing.T) {
	home := testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, DirsCmd, true)
	testutil.WantLines(t, out,
		"mkdir: "+home+"/.config/zsh [dry-run]",
		"mkdir: "+home+"/.cache/zsh [dry-run]", // make-extra-dirs entry
	)
}

// [<] 🤖🤖
