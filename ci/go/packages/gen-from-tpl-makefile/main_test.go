package main

import (
	"os"
	"path/filepath"
	"testing"

	"configs/ci/go/packages/gen-from-tpl-makefile/lib"
)

// [>] 🤖🤖🤖
func TestGenerateGolden(t *testing.T) {
	got, err := lib.Generate("testdata/Makefile")
	if err != nil {
		t.Fatalf("generate: %v", err)
	}
	wantBytes, err := os.ReadFile("testdata/expected.md")
	if err != nil {
		t.Fatalf("read golden: %v", err)
	}
	if got != string(wantBytes) {
		t.Errorf("output mismatch:\n--- got ---\n%s\n--- want ---\n%s", got, wantBytes)
	}
}

func TestGenerateMissing(t *testing.T) {
	if _, err := lib.Generate("testdata/nope.mk"); err == nil {
		t.Fatal("expected error for missing makefile")
	}
}

func TestCheck(t *testing.T) {
	dir := t.TempDir()
	mkSrc, _ := os.ReadFile("testdata/Makefile")
	if err := os.WriteFile(filepath.Join(dir, "Makefile"), mkSrc, 0o644); err != nil {
		t.Fatal(err)
	}
	doc, err := lib.Generate("testdata/Makefile")
	if err != nil {
		t.Fatal(err)
	}
	good := filepath.Join(dir, "good.md")
	stale := filepath.Join(dir, "stale.md")
	os.WriteFile(good, []byte(doc), 0o644)
	os.WriteFile(stale, []byte("stale\n"), 0o644)

	wd, _ := os.Getwd()
	defer os.Chdir(wd)
	os.Chdir(dir)

	if code := check(good); code != 0 {
		t.Errorf("check(good) = %d, want 0", code)
	}
	if code := check(stale); code != 22 {
		t.Errorf("check(stale) = %d, want 22", code)
	}
	if code := check(filepath.Join(dir, "absent.md")); code != 13 {
		t.Errorf("check(absent) = %d, want 13", code)
	}
}

//[<] 🤖🤖🤖
