package lib

import (
	"fmt"
	"path/filepath"
	"sort"
	"strings"

	git "github.com/go-git/go-git/v5"
)

// [>] 🤖🤖🤖
type treeNode map[string]treeNode

func TrackedFiles(repoPath string) ([]string, error) {
	repo, err := git.PlainOpenWithOptions(repoPath, &git.PlainOpenOptions{DetectDotGit: true})
	if err != nil {
		return nil, fmt.Errorf("not a git repo: %s: %w", repoPath, err)
	}
	idx, err := repo.Storer.Index()
	if err != nil {
		return nil, fmt.Errorf("read git index at %s: %w", repoPath, err)
	}
	files := make([]string, 0, len(idx.Entries))
	for _, e := range idx.Entries {
		files = append(files, e.Name)
	}
	return files, nil
}

func buildTree(paths []string) treeNode {
	root := treeNode{}
	for _, path := range paths {
		node := root
		dir := filepath.Dir(path)
		if dir == "." {
			continue
		}
		for part := range strings.SplitSeq(dir, string(filepath.Separator)) {
			child, ok := node[part]
			if !ok {
				child = treeNode{}
				node[part] = child
			}
			node = child
		}
	}
	return root
}

func renderTree(tree treeNode, depth int) string {
	names := make([]string, 0, len(tree))
	for name := range tree {
		names = append(names, name)
	}
	sort.Strings(names)
	var lines []string
	for _, name := range names {
		lines = append(lines, strings.Repeat("  ", depth)+name)
		if child := renderTree(tree[name], depth+1); child != "" {
			lines = append(lines, child)
		}
	}
	return strings.Join(lines, "\n")
}

func Generate(repoPath string) (string, error) {
	paths, err := TrackedFiles(repoPath)
	if err != nil {
		return "", err
	}
	return renderTree(buildTree(paths), 0) + "\n", nil
}

//[<] 🤖🤖🤖
