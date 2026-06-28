package main

// [>] 🤖

import (
	"fmt"
	"os"

	"configs/ci/go/packages/che/internal/cli"
)

func init() {
	cli.RootCmd.AddCommand(
		cli.LinkCmd,
		cli.CopyCmd,
		cli.RenderCmd,
		cli.DirsCmd,
		cli.PruneCmd,
		cli.InstallCmd,
		cli.DetectCmd,
		cli.ServicesCmd,
	)
}

func main() {
	if err := cli.RootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, "che:", err)
		os.Exit(1)
	}
}

// [<] 🤖
