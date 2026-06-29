package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// link: mkdir HOME config, link user zshrc into $HOME, backup then link /etc/zshrc.
func TestLinkCmd(t *testing.T) {
	home := setupDryRun(t)
	out := testutil.RunDry(t, LinkCmd, true)
	testutil.WantLines(t, out,
		"mkdir: "+home+"/.config/zsh [dry-run]",
		"ln: "+home+"/.config/zsh/.zshrc [dry-run]",
		"backup: /etc/zshrc.",
		"ln: /etc/zshrc [dry-run]",
	)
}

// [<] 🤖🤖
