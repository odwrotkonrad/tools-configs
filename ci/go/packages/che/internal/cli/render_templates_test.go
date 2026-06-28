package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// renders *.host.tpl into $HOME, marker stripped.
func TestRenderCmd(t *testing.T) {
	home := testutil.MockRepoEnv(t)
	dryRun = true
	t.Cleanup(func() { dryRun = false })
	if err := build(); err != nil {
		t.Fatalf("build() errored: %v", err)
	}

	out := testutil.RunDry(t, RenderCmd, true)
	testutil.WantLines(t, out, "render: "+home+"/.config/zsh/t [dry-run]")
}

// [<] 🤖🤖
