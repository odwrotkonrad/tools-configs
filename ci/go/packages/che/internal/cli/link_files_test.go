package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// link: mkdir HOME config, archive existing dests, link user zshrc into $HOME and /etc/zshrc.
func TestLinkCmd(t *testing.T) {
	home := setupDryRun(t)
	out := testutil.RunDry(t, LinkCmd, true)
	testutil.WantLines(t, out,
		"mkdir: "+home+"/.config/zsh [dry-run]",
		"ln: "+home+"/.config/zsh/.zshrc [dry-run]",
		"archive: "+home+"/.local/share/che/backups/che-link-",
		"ln: /etc/zshrc [dry-run]",
	)
}

// [<] 🤖🤖
