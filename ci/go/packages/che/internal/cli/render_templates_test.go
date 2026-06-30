package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// renders *.host.tpl into $HOME, marker stripped.
func TestRenderCmd(t *testing.T) {
	home := setupDryRun(t)
	out := testutil.RunDry(t, RenderCmd, true)
	testutil.WantLines(t, out, "render(dry-run): "+home+"/.config/zsh/t")
}

// [<] 🤖🤖
