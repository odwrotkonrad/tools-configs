package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// [>] 🤖🤖🤖
const includeTag = "[genai-include]"

const usage = `usage: tpl-gen-makefile-doc <makefile-path>
       tpl-gen-makefile-doc --check <doc-file>

Emit makefile.agents.md from a Makefile's [genai-include] sections (stdout).
--check regenerates from ./Makefile and diffs against <doc-file>:
exit 0 match, 22 differ (unified diff on stderr).
`

func main() {
	args := os.Args[1:]
	switch {
	case len(args) == 1 && (args[0] == "-h" || args[0] == "--help"):
		fmt.Print(usage)
	case len(args) == 2 && args[0] == "--check":
		os.Exit(check(args[1]))
	case len(args) == 1 && !strings.HasPrefix(args[0], "-"):
		out, err := generate(args[0])
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Print(out)
	default:
		fmt.Fprintf(os.Stderr, "invalid arguments: %v\n\n%s", args, usage)
		os.Exit(11)
	}
}

func generate(path string) (string, error) {
	src, err := os.ReadFile(path)
	if err != nil {
		return "", fmt.Errorf("file not found: %s", path)
	}
	sections, err := parse(src)
	if err != nil {
		return "", err
	}
	return render(sections), nil
}

func check(docPath string) int {
	want, err := os.ReadFile(docPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "file not found: %s\n", docPath)
		return 13
	}
	got, err := generate("Makefile")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	if got == string(want) {
		return 0
	}
	fmt.Fprint(os.Stderr, diff(string(want), got, docPath))
	return 22
}

func diff(want, got, label string) string {
	wf, _ := os.CreateTemp("", "doc-want-*")
	gf, _ := os.CreateTemp("", "doc-got-*")
	defer os.Remove(wf.Name())
	defer os.Remove(gf.Name())
	wf.WriteString(want)
	gf.WriteString(got)
	wf.Close()
	gf.Close()
	out, _ := exec.Command("diff", "-u",
		"--label", label, "--label", "generated",
		wf.Name(), gf.Name()).Output()
	return string(out)
}

//[<] 🤖🤖🤖
