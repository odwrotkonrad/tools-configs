package cli

// [>] 🤖🤖

import "github.com/spf13/cobra"

var InstallCmd = &cobra.Command{
	Use:   "install-tools",
	Short: "run the profile's install units",
	RunE: func(cmd *cobra.Command, args []string) error {
		scripts, err := theHost.ResolveInstall(resolved.Installs)
		if err != nil {
			return err
		}
		return theHost.Install(scripts)
	},
}

// [<] 🤖🤖
