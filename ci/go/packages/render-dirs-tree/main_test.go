package main

import (
	"os"
	"path/filepath"
	"testing"

	git "github.com/go-git/go-git/v5"

	"configs/ci/go/packages/render-dirs-tree/lib"
)

// [>] 🤖🤖🤖
func initRepo(t *testing.T, files []string) string {
	t.Helper()
	dir := t.TempDir()
	repo, err := git.PlainInit(dir, false)
	if err != nil {
		t.Fatalf("init: %v", err)
	}
	wt, err := repo.Worktree()
	if err != nil {
		t.Fatalf("worktree: %v", err)
	}
	for _, f := range files {
		abs := filepath.Join(dir, f)
		if err := os.MkdirAll(filepath.Dir(abs), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(abs, []byte("x"), 0o644); err != nil {
			t.Fatal(err)
		}
		if _, err := wt.Add(f); err != nil {
			t.Fatalf("add %s: %v", f, err)
		}
	}
	return dir
}

func TestGenerateGolden(t *testing.T) {
	dir := initRepo(t, []string{
		"top",
		".hidden/file",
		"docs/data/x",
		"src/lib/y",
	})
	got, err := lib.Generate(dir)
	if err != nil {
		t.Fatalf("generate: %v", err)
	}
	wantBytes, err := os.ReadFile("testdata/expected.tree")
	if err != nil {
		t.Fatalf("read golden: %v", err)
	}
	if got != string(wantBytes) {
		t.Errorf("output mismatch:\n--- got ---\n%s\n--- want ---\n%s", got, wantBytes)
	}
}

func TestGenerateMissing(t *testing.T) {
	if _, err := lib.Generate(t.TempDir()); err == nil {
		t.Fatal("expected error outside a git repo")
	}
}

func TestCheck(t *testing.T) {
	dir := initRepo(t, []string{"top", ".hidden/file", "docs/data/x", "src/lib/y"})
	tree, err := lib.Generate(dir)
	if err != nil {
		t.Fatal(err)
	}
	good := filepath.Join(dir, "good.tree")
	stale := filepath.Join(dir, "stale.tree")
	os.WriteFile(good, []byte(tree), 0o644)
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
	if code := check(filepath.Join(dir, "absent.tree")); code != 13 {
		t.Errorf("check(absent) = %d, want 13", code)
	}
}

//[<] 🤖🤖🤖
