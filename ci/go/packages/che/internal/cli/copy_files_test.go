package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// copy: copies the *.host.cp into $HOME (marker stripped), and backs up + copies the
// root-owned daemon plist, then chowns it root:wheel.
func TestCopyCmd(t *testing.T) {
	home := testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, CopyCmd, true)
	testutil.WantLines(t, out,
		"cp: "+home+"/.config/zsh/c [dry-run]",
		"backup: /Library/LaunchDaemons/otelcol.plist.",
		"cp: /Library/LaunchDaemons/otelcol.plist [dry-run]",
		"chown: root:wheel /Library/LaunchDaemons/otelcol.plist [dry-run]",
	)
}

// [<] 🤖🤖
