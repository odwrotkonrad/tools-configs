package cli

// [>] 🤖🤖

import "github.com/spf13/cobra"

var RenderCmd = &cobra.Command{
	Use:   "render-templates",
	Short: "*.host.tpl render pass",
	RunE: func(cmd *cobra.Command, args []string) error {
		return theHost.RenderTemplates(resolved.Templates)
	},
}

// [<] 🤖🤖
