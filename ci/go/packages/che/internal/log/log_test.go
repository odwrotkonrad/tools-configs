package log

// [>] 🤖🤖

import (
	"regexp"
	"strings"
	"testing"

	"configs/ci/go/packages/che/internal/testutil"
)

func capture(t *testing.T, fn func()) string {
	t.Helper()
	out, _ := testutil.CaptureStdout(t, func() error { fn(); return nil })
	return out
}

var lineRe = regexp.MustCompile(`^\d{2}:\d{2}:\d{2}\.\d{3}: ([^:]+): (.*)\n$`)

func TestMsgFormat(t *testing.T) {
	out := capture(t, func() { Msg("ln", "/etc/zshrc", false) })
	m := lineRe.FindStringSubmatch(out)
	if m == nil {
		t.Fatalf("output %q does not match HH:MM:SS.mmm: title: msg", out)
	}
	if m[1] != "ln" || m[2] != "/etc/zshrc" {
		t.Errorf("title/msg = %q/%q, want ln//etc/zshrc", m[1], m[2])
	}
}

func TestMsgDryRunSuffix(t *testing.T) {
	dry := capture(t, func() { Msg("cp", "/x", true) })
	if !strings.HasSuffix(dry, "cp: /x [dry-run]\n") {
		t.Errorf("dry-run line %q must end with the [dry-run] suffix", dry)
	}
	wet := capture(t, func() { Msg("cp", "/x", false) })
	if strings.Contains(wet, "[dry-run]") {
		t.Errorf("non-dry-run line %q must not carry [dry-run]", wet)
	}
}

// [<] 🤖🤖
