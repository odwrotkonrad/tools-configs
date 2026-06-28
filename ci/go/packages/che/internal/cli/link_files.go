package cli

// [>] 🤖🤖

import "github.com/spf13/cobra"

var LinkCmd = &cobra.Command{
	Use:   "link",
	Short: "symlink pass (configs into system root)",
	RunE: func(cmd *cobra.Command, args []string) error {
		return theHost.MkLinks(resolved.Links, resolved.Dirs)
	},
}

// [<] 🤖🤖
