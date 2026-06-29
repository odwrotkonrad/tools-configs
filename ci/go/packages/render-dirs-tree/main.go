package main

import (
	"fmt"
	"os"
	"os/exec"

	"configs/ci/go/packages/render-dirs-tree/lib"
)

// [>] 🤖🤖🤖
const usage = `usage: render-dirs-tree
       render-dirs-tree --check <file>

Print the plain directory tree of the cwd repo's tracked files (stdout):
read tracked paths from the git index, drop each file leaf, nest and sort
the remaining dirs, 2-space indented, one dir per line.
--check regenerates and diffs against <file>:
exit 0 match, 22 differ (unified diff on stderr).
`

func main() {
	args := os.Args[1:]
	switch {
	case len(args) == 1 && (args[0] == "-h" || args[0] == "--help"):
		fmt.Print(usage)
	case len(args) == 2 && args[0] == "--check":
		os.Exit(check(args[1]))
	case len(args) == 0:
		out, err := lib.Generate(".")
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(21)
		}
		fmt.Print(out)
	default:
		fmt.Fprintf(os.Stderr, "invalid arguments: %v\n\n%s", args, usage)
		os.Exit(11)
	}
}

func check(path string) int {
	want, err := os.ReadFile(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "file not found: %s\n", path)
		return 13
	}
	got, err := lib.Generate(".")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 21
	}
	if got == string(want) {
		return 0
	}
	fmt.Fprint(os.Stderr, diff(string(want), got, path))
	return 22
}

func diff(want, got, label string) string {
	wf, _ := os.CreateTemp("", "tree-want-*")
	gf, _ := os.CreateTemp("", "tree-got-*")
	defer os.Remove(wf.Name())
	defer os.Remove(gf.Name())
	wf.WriteString(want)
	gf.WriteString(got)
	wf.Close()
	gf.Close()
	out, _ := exec.Command("diff", "-u",
		"--label", label, "--label", "render-dirs-tree",
		wf.Name(), gf.Name()).Output()
	return string(out)
}

//[<] 🤖🤖🤖
