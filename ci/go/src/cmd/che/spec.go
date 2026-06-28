package main

// [>] 🤖🤖🤖

import (
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"gopkg.in/yaml.v3"
)

// spec mirrors che.yml. profiles is the enum tree (declared detectable leaves);
// the remaining top-level keys hold defined blocks: leaf profiles
// ("bare-metal/mac-os-aarch64", ...) and included profiles ("base-cli", ...).
type spec struct {
	Profiles map[string]any         `yaml:"profiles"`
	profiles map[string]profileSpec // every defined block, keyed by name
}

// profileSpec is one block. A leaf names include-profiles (merged in order); an
// included profile carries the actual config sections. Both may carry inline
// sections, appended after the includes. include/exclude add/remove whole sections
// after composition (exclude wins, applied last).
type profileSpec struct {
	IncludeProfiles   []string       `yaml:"include-profiles"`
	LoadConfiguration map[string]any `yaml:"load-configuration"`
	MakeExtraDirs     []string       `yaml:"make-extra-dirs"`
	Install           []string       `yaml:"install"`
	Include           sectionSet     `yaml:"include"`
	Exclude           sectionSet     `yaml:"exclude"`
}

// sectionSet is the include/exclude payload: extra profiles to compose plus
// per-section path/unit lists.
type sectionSet struct {
	Profiles          []string `yaml:"profiles"`
	LoadConfiguration []string `yaml:"load-configuration"`
	MakeExtraDirs     []string `yaml:"make-extra-dirs"`
	Install           []string `yaml:"install"`
}

// effective is the detected profile's composed selection. load-configuration is an
// ordered op list (include +/exclude −) in composition order; a file is selected
// iff the LAST op matching it is an include. This lets a later profile re-include
// what an earlier one excluded (base-desktop +kitty beats base-cli −kitty).
// dirs/install are exact-subtracted as they merge.
type effective struct {
	globOps []globOp // ordered include/exclude globs (relative to root/)
	dirs    []string // make-extra-dirs
	install []string // install unit paths relative to repo root (order = run order)
}

type globOp struct {
	pattern string
	include bool // true = include, false = exclude
}

// loadSpec parses che.yml: the `profiles:` enum, plus every other top-level key
// as a defined block (leaf profiles and included profiles alike).
func loadSpec(path string) (*spec, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("spec not found: %s", path)
	}
	var raw map[string]yaml.Node
	if err := yaml.Unmarshal(b, &raw); err != nil {
		return nil, fmt.Errorf("parse %s: %w", path, err)
	}
	s := &spec{profiles: map[string]profileSpec{}}
	for key, node := range raw {
		if key == "profiles" {
			if err := node.Decode(&s.Profiles); err != nil {
				return nil, fmt.Errorf("parse profiles enum: %w", err)
			}
			continue
		}
		var ps profileSpec
		if err := node.Decode(&ps); err != nil {
			return nil, fmt.Errorf("parse profile %q: %w", key, err)
		}
		s.profiles[key] = ps
	}
	return s, nil
}

// resolveEffective validates the detected profile is defined, then merges its
// include-profiles (in listed order, recursively) followed by its own inline
// sections. Each named include must exist; cycles error.
func (s *spec) resolveEffective(profile string) (effective, error) {
	if !s.isDetectable(profile) {
		return effective{}, fmt.Errorf(
			"detected profile %q is not defined in che.yml (defined: %v)",
			profile, s.detectableLeaves())
	}
	eff := effective{}
	if err := s.mergeInto(&eff, profile, nil); err != nil {
		return effective{}, err
	}
	// brace-expand all path/glob lists (zsh-style {a,b}); ops keep their order
	eff.globOps = expandOps(eff.globOps)
	eff.dirs = expandAll(eff.dirs)
	eff.install = expandAll(eff.install)
	return eff, nil
}

// expandOps brace-expands each op's pattern, preserving op order and include flag.
func expandOps(ops []globOp) []globOp {
	var out []globOp
	for _, op := range ops {
		for _, p := range expandBraces(op.pattern) {
			out = append(out, globOp{pattern: p, include: op.include})
		}
	}
	return out
}

// removeAll returns xs with every element of drop removed (exact match).
func removeAll(xs, drop []string) []string {
	if len(drop) == 0 {
		return xs
	}
	out := xs[:0:0]
	for _, x := range xs {
		if !slices.Contains(drop, x) {
			out = append(out, x)
		}
	}
	return out
}

// mergeInto composes name into eff: its include-profiles (depth-first, in order),
// its inline sections, then its own include (additive) and exclude (subtractive
// for dirs/install; exclude globs accumulate for file-time filtering). seen tracks
// the active chain to catch cycles.
func (s *spec) mergeInto(eff *effective, name string, seen []string) error {
	if slices.Contains(seen, name) {
		return fmt.Errorf("include-profiles cycle: %v -> %s", seen, name)
	}
	ps, ok := s.profiles[name]
	if !ok {
		return fmt.Errorf("include-profiles names undefined profile %q (from %v)", name, seen)
	}
	for _, inc := range ps.IncludeProfiles {
		if err := s.mergeInto(eff, inc, append(seen, name)); err != nil {
			return err
		}
	}
	for _, inc := range ps.Include.Profiles {
		if err := s.mergeInto(eff, inc, append(seen, name)); err != nil {
			return err
		}
	}
	// load-configuration as ordered ops: this block's includes (+), then its
	// excludes (−). Appended in composition order so later profiles override earlier.
	for _, g := range sortedKeys(ps.LoadConfiguration) {
		eff.globOps = append(eff.globOps, globOp{g, true})
	}
	for _, g := range ps.Include.LoadConfiguration {
		eff.globOps = append(eff.globOps, globOp{g, true})
	}
	for _, g := range ps.Exclude.LoadConfiguration {
		eff.globOps = append(eff.globOps, globOp{g, false})
	}
	// dirs/install: additive include, subtractive exclude (exact match)
	eff.dirs = append(eff.dirs, ps.MakeExtraDirs...)
	eff.dirs = append(eff.dirs, ps.Include.MakeExtraDirs...)
	eff.dirs = removeAll(eff.dirs, ps.Exclude.MakeExtraDirs)
	eff.install = append(eff.install, ps.Install...)
	eff.install = append(eff.install, ps.Include.Install...)
	eff.install = removeAll(eff.install, ps.Exclude.Install)
	return nil
}

// isDetectable reports whether profile is both declared in the enum and defined.
func (s *spec) isDetectable(profile string) bool {
	_, defined := s.profiles[profile]
	return defined && s.declared(profile)
}

// declared walks the profiles enum tree for the "<space>/<os>-<arch>" leaf.
func (s *spec) declared(profile string) bool {
	parts := strings.SplitN(profile, "/", 2)
	if len(parts) != 2 {
		return false
	}
	space, ok := s.Profiles[parts[0]].(map[string]any)
	if !ok {
		return false
	}
	_, ok = space[parts[1]]
	return ok
}

// detectableLeaves lists the enum leaves that are also defined.
func (s *spec) detectableLeaves() []string {
	var out []string
	for space, leaves := range s.Profiles {
		m, ok := leaves.(map[string]any)
		if !ok {
			continue
		}
		for leaf := range m {
			name := space + "/" + leaf
			if _, defined := s.profiles[name]; defined {
				out = append(out, name)
			}
		}
	}
	return sortedSlice(out)
}

func sortedKeys(m map[string]any) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	return sortedSlice(out)
}

// specPath finds che.yml at the repo root (walk up from cwd).
func specPath() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		p := filepath.Join(dir, "che.yml")
		if _, err := os.Stat(p); err == nil {
			return p, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("che.yml not found from cwd upward")
		}
		dir = parent
	}
}

// [<] 🤖🤖🤖
