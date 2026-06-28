package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
)

const usage = `usage: che [--dry-run] <command>

Spec-driven config loader. Detects OS+arch+virt -> profile in che.yml,
loads only the files/dirs/installs that profile selects.

Commands:
  link              symlink pass (configs into system root)
  copy              *.host.cp copy pass
  render-templates  *.host.tpl render pass
  mk-dirs           create repo-tree dirs + also-create-dirs
  prune-links       delete broken symlinks
  install-tools     run the profile's install units
  sync              prune-links, mk-dirs, link, copy, render-templates
  detect            print the detected profile and exit

Flags:
  --dry-run         print mutating actions instead of executing them
`

func main() {
	args, dryRun := extractDryRun(os.Args[1:])
	if len(args) == 0 {
		fmt.Fprint(os.Stderr, usage)
		os.Exit(11)
	}
	cmd := args[0]
	if cmd == "-h" || cmd == "--help" {
		fmt.Print(usage)
		return
	}

	app, err := newApp(dryRun)
	if err != nil {
		fatal(err)
	}

	switch cmd {
	case "detect":
		fmt.Println(app.profile)
	case "link":
		err = app.passLink()
	case "copy":
		err = app.passCopy()
	case "render-templates":
		err = app.passTmpl()
	case "mk-dirs":
		err = app.passDirs()
	case "prune-links":
		err = app.passPrune()
	case "install-tools":
		err = app.passInstall()
	case "sync":
		err = app.sync()
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n\n%s", cmd, usage)
		os.Exit(11)
	}
	if err != nil {
		fatal(err)
	}
}

// extractDryRun strips --dry-run from anywhere in args, returns the rest + the flag.
func extractDryRun(in []string) ([]string, bool) {
	out := in[:0:0]
	dry := false
	for _, a := range in {
		if a == "--dry-run" {
			dry = true
			continue
		}
		out = append(out, a)
	}
	return out, dry
}

func fatal(err error) {
	fmt.Fprintln(os.Stderr, "che:", err)
	os.Exit(1)
}

// [<] 🤖🤖🤖
