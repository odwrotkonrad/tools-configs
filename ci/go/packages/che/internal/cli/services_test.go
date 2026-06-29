package cli

// [>] 🤖🤖

import (
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

// each services subcommand resolves profile services (fixture: one, otelcol, a system daemon) then dispatches. dry-run logs the full target.
func TestServicesSubcommands(t *testing.T) {
	cases := map[string]string{
		"bootout": "bootout: system/otelcol [dry-run]",
		"bootin":  "bootstrap: system/otelcol [dry-run]",
		"ensure":  "ensure: system/otelcol [dry-run]",
	}
	for name, want := range cases {
		t.Run(name, func(t *testing.T) {
			setupDryRun(t)
			sub, _, err := ServicesCmd.Find([]string{name})
			if err != nil || sub == ServicesCmd {
				t.Fatalf("services subcommand %q not found: %v", name, err)
			}
			out := testutil.RunDry(t, sub, true)
			testutil.WantLines(t, out, want)
		})
	}
}

// [<] 🤖🤖
