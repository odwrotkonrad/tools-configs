package lib

// [>] 🤖🤖🤖

import "testing"

func TestSectionOpen(t *testing.T) {
	cases := []struct {
		text  string
		label string
		depth int
		ok    bool
	}{
		{"##[>] Onto Host [genai-include]", "Onto Host", 0, true},
		{"##[>] Onto Repo (CI) [genai-include] 🤖🤖", "Onto Repo (CI)", 0, true},
		{"###[>] VM", "VM", 1, true},
		{"##[>] go 🤖🤖", "go", 0, true},
		{"#[what] not a section", "", 0, false},
	}
	for _, c := range cases {
		label, depth, ok := sectionOpen(c.text)
		if ok != c.ok || label != c.label || (ok && depth != c.depth) {
			t.Errorf("sectionOpen(%q) = (%q,%d,%v), want (%q,%d,%v)",
				c.text, label, depth, ok, c.label, c.depth, c.ok)
		}
	}
}

//[<] 🤖🤖🤖
