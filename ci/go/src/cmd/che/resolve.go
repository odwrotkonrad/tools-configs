package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

const (
	tmplExt = ".host.auto.tmpl"
	cpExt   = ".host.auto.cp"
)

// classified config files for the load passes, all repo-relative under root/.
type configSet struct {
	links     []string // link pass: regular files minus templates/copies/.gitkeep
	copies    []string // copy pass: *.host.auto.cp
	templates []string // render pass: *.host.auto.tmpl
	dirs      []string // every ancestor dir of links+copies+templates (repo-relative)
}

// resolveConfigs expands the effective load-configuration globs against the
// git-tracked files under root/ (mirrors upsert-configs' `git ls-files`), and classifies.
func (a *app) resolveConfigs() (configSet, error) {
	tracked, err := a.trackedFiles()
	if err != nil {
		return configSet{}, err
	}
	var matched []string
	for _, rel := range tracked {
		if a.selected(rel) {
			matched = append(matched, rel)
		}
	}
	cs := configSet{}
	dirSeen := map[string]bool{}
	for _, rel := range matched {
		switch {
		case strings.HasSuffix(rel, tmplExt):
			cs.templates = append(cs.templates, rel)
		case strings.HasSuffix(rel, cpExt):
			cs.copies = append(cs.copies, rel)
		case filepath.Base(rel) == ".gitkeep":
			// excluded from every pass
		default:
			cs.links = append(cs.links, rel)
		}
		for d := filepath.Dir(rel); d != "." && !dirSeen[d]; d = filepath.Dir(d) {
			dirSeen[d] = true
			cs.dirs = append(cs.dirs, d)
		}
	}
	sort.Strings(cs.links)
	sort.Strings(cs.copies)
	sort.Strings(cs.templates)
	sort.Strings(cs.dirs) // lexical -> parents before children
	return cs, nil
}

// selected applies the ordered load-configuration ops: a file is selected iff the
// LAST op whose glob matches it is an include. Unmatched files are not selected.
func (a *app) selected(rel string) bool {
	sel := false
	for _, op := range a.eff.globOps {
		if matchGlob(strings.TrimSuffix(op.pattern, "/"), rel) {
			sel = op.include
		}
	}
	return sel
}

// trackedFiles lists git-tracked files under root/, repo-relative to root/.
func (a *app) trackedFiles() ([]string, error) {
	cmd := exec.Command("git", "-C", a.root, "ls-files", "--exclude-standard")
	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("git ls-files under %s: %w", a.root, err)
	}
	var files []string
	for _, line := range strings.Split(strings.TrimRight(string(out), "\n"), "\n") {
		if line != "" {
			files = append(files, line)
		}
	}
	return files, nil
}

// matchGlob matches a path against a pattern where ** spans path separators,
// * spans a single segment, and a literal prefix may end in * (suffix glob).
func matchGlob(pattern, path string) bool {
	// ** : match this dir and everything under it
	if strings.HasSuffix(pattern, "/**") {
		base := strings.TrimSuffix(pattern, "/**")
		return path == base || strings.HasPrefix(path, base+"/")
	}
	if strings.Contains(pattern, "**") {
		return doublestar(pattern, path)
	}
	// single-segment * and trailing-* (e.g. foo.plist*) handled by filepath.Match
	ok, err := filepath.Match(pattern, path)
	return err == nil && ok
}

// doublestar handles patterns with an interior **.
func doublestar(pattern, path string) bool {
	parts := strings.SplitN(pattern, "**", 2)
	pre, post := parts[0], strings.TrimPrefix(parts[1], "/")
	if !strings.HasPrefix(path, pre) {
		return false
	}
	rest := strings.TrimPrefix(path, pre)
	if post == "" {
		return true
	}
	tail := rest
	if i := strings.LastIndex(rest, "/"); i >= 0 {
		tail = rest[i+1:]
	}
	ok, _ := filepath.Match(post, tail)
	return ok
}

// resolveInstall expands the install list IN SPEC ORDER (no sort). Each entry must
// resolve to >=1 script (catches typos/renames). Trailing-* globs expand in place.
func (a *app) resolveInstall() ([]string, error) {
	var out []string
	for _, entry := range a.eff.install {
		abs := filepath.Join(a.repoRoot, entry)
		if strings.ContainsAny(entry, "*?[") {
			hits, err := filepath.Glob(abs)
			if err != nil {
				return nil, err
			}
			if len(hits) == 0 {
				return nil, fmt.Errorf("install entry matched no script: %s", entry)
			}
			sort.Strings(hits)
			out = append(out, hits...)
			continue
		}
		if _, err := os.Stat(abs); err != nil {
			return nil, fmt.Errorf("install script not found: %s", entry)
		}
		out = append(out, abs)
	}
	return out, nil
}

// expandBraces expands one or more {a,b,c} groups in a pattern into the cartesian
// product of alternatives (zsh-style), e.g. "x/{a,b}/y" -> ["x/a/y","x/b/y"].
// Patterns without braces return themselves.
func expandBraces(pattern string) []string {
	open := strings.IndexByte(pattern, '{')
	if open < 0 {
		return []string{pattern}
	}
	depth, close := 0, -1
	for i := open; i < len(pattern); i++ {
		switch pattern[i] {
		case '{':
			depth++
		case '}':
			depth--
			if depth == 0 {
				close = i
			}
		}
		if close >= 0 {
			break
		}
	}
	if close < 0 {
		return []string{pattern} // unbalanced; leave as-is
	}
	pre, body, post := pattern[:open], pattern[open+1:close], pattern[close+1:]
	var out []string
	for _, alt := range splitTopLevel(body) {
		for _, rest := range expandBraces(pre + alt + post) {
			out = append(out, rest)
		}
	}
	return out
}

// splitTopLevel splits a brace body on commas not nested in inner braces.
func splitTopLevel(body string) []string {
	var parts []string
	depth, start := 0, 0
	for i := 0; i < len(body); i++ {
		switch body[i] {
		case '{':
			depth++
		case '}':
			depth--
		case ',':
			if depth == 0 {
				parts = append(parts, body[start:i])
				start = i + 1
			}
		}
	}
	return append(parts, body[start:])
}

// expandAll brace-expands every pattern in xs, flattening the result.
func expandAll(xs []string) []string {
	var out []string
	for _, x := range xs {
		out = append(out, expandBraces(x)...)
	}
	return out
}

func sortedSlice(in []string) []string {
	out := append([]string(nil), in...)
	sort.Strings(out)
	return out
}

// [<] 🤖🤖🤖
