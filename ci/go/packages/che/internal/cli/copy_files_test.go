package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// copy: *.host.cp into $HOME (marker stripped); backup, copy, chown root:wheel the daemon plist.
func TestCopyCmd(t *testing.T) {
	home := setupDryRun(t)
	out := testutil.RunDry(t, CopyCmd, true)
	testutil.WantLines(t, out,
		"cp: "+home+"/.config/zsh/c [dry-run]",
		"backup: /Library/LaunchDaemons/otelcol.plist.",
		"cp: /Library/LaunchDaemons/otelcol.plist [dry-run]",
		"chown: root:wheel /Library/LaunchDaemons/otelcol.plist [dry-run]",
	)
}

// [<] 🤖🤖
