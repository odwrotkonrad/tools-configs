package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// mk-dirs: repo-tree config dirs plus profile extra-dir, under $HOME.
func TestDirsCmd(t *testing.T) {
	home := setupDryRun(t)
	out := testutil.RunDry(t, DirsCmd, true)
	testutil.WantLines(t, out,
		"mkdir: "+home+"/.config/zsh [dry-run]",
		"mkdir: "+home+"/.cache/zsh [dry-run]",           // mkdirs entry
		"mkdir: /var/log/che-test-setgid [dry-run]",      // setgid mkdirs entry
		"chmod: 2775 /var/log/che-test-setgid [dry-run]", // spec chmod reapplied for setgid bit
	)
}

// [<] 🤖🤖
