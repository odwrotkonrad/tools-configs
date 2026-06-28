package cli

// [>] 🤖🤖

import (
	"testing"

	"github.com/spf13/cobra"

	"configs/ci/go/packages/che/internal/testutil"
)

// each services subcommand resolves the profile's services (the fixture has one,
// otelcol, a system daemon) then dispatches; in dry-run each logs the full target.
func TestServicesSubcommands(t *testing.T) {
	cases := map[string]string{
		"bootout": "bootout: system/otelcol [dry-run]",
		"bootin":  "bootstrap: system/otelcol [dry-run]",
		"ensure":  "ensure: system/otelcol [dry-run]",
	}
	for name, want := range cases {
		t.Run(name, func(t *testing.T) {
			testutil.MockRepoEnv(t)
			dryRun = true
			t.Cleanup(func() { dryRun = false })
			if err := build(); err != nil {
				t.Fatalf("build() errored: %v", err)
			}

			var sub *cobra.Command
			for _, c := range ServicesCmd.Commands() {
				if c.Name() == name {
					sub = c
				}
			}
			if sub == nil {
				t.Fatalf("services subcommand %q not found", name)
			}
			out := testutil.RunDry(t, sub, true)
			testutil.WantLines(t, out, want)
		})
	}
}

// [<] 🤖🤖
