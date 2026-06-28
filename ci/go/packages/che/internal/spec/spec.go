package spec

// [>] 🤖🤖

import (
	"fmt"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"gopkg.in/yaml.v3"

	"configs/ci/go/packages/che/internal/fsutil"
)

const (
	TmplExt = ".host.tpl"
	CpExt   = ".host.cp"
)

// Raw mirrors che.yml. Profiles is the enum tree of declared leaves; other
// top-level keys are defined blocks: leaf profiles and included profiles.
type Raw struct {
	Profiles map[string]any         `yaml:"profiles"`
	profiles map[string]profileSpec // every defined block, keyed by name
}

// profileSpec is one block. A leaf names include-profiles (merged in order), an
// included profile carries config sections. Both may carry inline sections,
// appended after includes. include/exclude add/remove sections post-composition
// (exclude wins, applied last).
type profileSpec struct {
	IncludeProfiles   []string       `yaml:"include-profiles"`
	LoadConfiguration map[string]any `yaml:"load-configuration"`
	MakeExtraDirs     []string       `yaml:"make-extra-dirs"`
	Install           []string       `yaml:"install"`
	Services          []string       `yaml:"services"`
	Include           sectionSet     `yaml:"include"`
	Exclude           sectionSet     `yaml:"exclude"`
}

// sectionSet is the include/exclude payload: extra profiles plus per-section
// path/unit lists.
type sectionSet struct {
	Profiles          []string `yaml:"profiles"`
	LoadConfiguration []string `yaml:"load-configuration"`
	MakeExtraDirs     []string `yaml:"make-extra-dirs"`
	Install           []string `yaml:"install"`
	Services          []string `yaml:"services"`
}

// effective is the composed selection before file classification. globOps is
// ordered (include +/exclude −) in composition order, a file is selected iff its
// LAST matching op is an include. Dirs/Install/Services exact-subtract on merge.
type effective struct {
	globOps  []globOp // ordered include/exclude globs (relative to root/)
	dirs     []string // make-extra-dirs
	install  []string // install unit paths relative to repo root (order = run order)
	services []string // service names (compositional like install)
}

type globOp struct {
	pattern string
	include bool // true = include, false = exclude
}

// Resolved is the classified, repo-relative selection the passes consume.
// Links/Copies/Templates/Dirs are under root/, Installs/Services are spec lists.
type Resolved struct {
	Links     []string // link pass: regular files minus templates/copies/.gitkeep
	Copies    []string // copy pass: *.host.cp
	Templates []string // render pass: *.host.tpl
	Dirs      []string // every ancestor dir of links+copies+templates, plus make-extra-dirs
	ExtraDirs []string // make-extra-dirs only (live dest entries)
	Services  []string // service names (compositional)
	Installs  []string // install unit entries in spec order
}

// Load parses che.yml: the `profiles:` enum plus every other top-level key as a
// defined block.
func Load(path string) (*Raw, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("spec not found: %s", path)
	}
	var raw map[string]yaml.Node
	if err := yaml.Unmarshal(b, &raw); err != nil {
		return nil, fmt.Errorf("parse %s: %w", path, err)
	}
	s := &Raw{profiles: map[string]profileSpec{}}
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

// Resolve validates the profile is defined, composes its include-profiles and
// inline sections, then classifies git-tracked files under root into
// Links/Copies/Templates/Dirs. Output is repo-relative.
func (r *Raw) Resolve(profile, root string) (Resolved, error) {
	if !r.isDetectable(profile) {
		return Resolved{}, fmt.Errorf(
			"detected profile %q is not defined in che.yml (defined: %v)",
			profile, r.detectableLeaves())
	}
	eff := effective{}
	if err := r.mergeInto(&eff, profile, nil); err != nil {
		return Resolved{}, err
	}
	// brace-expand path/glob lists (zsh-style {a,b}), ops keep order
	eff.globOps = expandOps(eff.globOps)
	res := Resolved{
		ExtraDirs: fsutil.ExpandAll(eff.dirs),
		Installs:  fsutil.ExpandAll(eff.install),
		Services:  fsutil.ExpandAll(eff.services),
	}
	if err := classify(root, eff.globOps, &res); err != nil {
		return Resolved{}, err
	}
	return res, nil
}

// classify applies the load-configuration ops to git-tracked files under root,
// bucketing them into Links/Copies/Templates plus ancestor Dirs.
func classify(root string, ops []globOp, res *Resolved) error {
	tracked, err := fsutil.TrackedFiles(root)
	if err != nil {
		return err
	}
	dirSeen := map[string]bool{}
	for _, rel := range tracked {
		if !selected(ops, rel) {
			continue
		}
		switch {
		case strings.HasSuffix(rel, TmplExt):
			res.Templates = append(res.Templates, rel)
		case strings.HasSuffix(rel, CpExt):
			res.Copies = append(res.Copies, rel)
		case filepath.Base(rel) == ".gitkeep":
			// excluded from every pass
		default:
			res.Links = append(res.Links, rel)
		}
		for d := filepath.Dir(rel); d != "." && !dirSeen[d]; d = filepath.Dir(d) {
			dirSeen[d] = true
			res.Dirs = append(res.Dirs, d)
		}
	}
	slices.Sort(res.Links)
	slices.Sort(res.Copies)
	slices.Sort(res.Templates)
	slices.Sort(res.Dirs) // lexical, parents before children
	return nil
}

// selected: a file is selected iff its LAST matching op is an include.
func selected(ops []globOp, rel string) bool {
	sel := false
	for _, op := range ops {
		if fsutil.MatchGlob(strings.TrimSuffix(op.pattern, "/"), rel) {
			sel = op.include
		}
	}
	return sel
}

// expandOps brace-expands each op's pattern, preserving op order and include flag.
func expandOps(ops []globOp) []globOp {
	var out []globOp
	for _, op := range ops {
		for _, p := range fsutil.ExpandBraces(op.pattern) {
			out = append(out, globOp{pattern: p, include: op.include})
		}
	}
	return out
}

// mergeInto composes name into eff: include-profiles (depth-first), inline
// sections, then its include (additive) and exclude (subtractive for
// dirs/install/services, exclude globs accumulate for file-time filtering).
// seen tracks the active chain to catch cycles.
func (r *Raw) mergeInto(eff *effective, name string, seen []string) error {
	if slices.Contains(seen, name) {
		return fmt.Errorf("include-profiles cycle: %v -> %s", seen, name)
	}
	ps, ok := r.profiles[name]
	if !ok {
		return fmt.Errorf("include-profiles names undefined profile %q (from %v)", name, seen)
	}
	child := append(slices.Clone(seen), name)
	for _, inc := range ps.IncludeProfiles {
		if err := r.mergeInto(eff, inc, child); err != nil {
			return err
		}
	}
	for _, inc := range ps.Include.Profiles {
		if err := r.mergeInto(eff, inc, child); err != nil {
			return err
		}
	}
	// load-configuration ops: includes (+) then excludes (−), in composition
	// order so later profiles override earlier
	for _, g := range sortedKeys(ps.LoadConfiguration) {
		eff.globOps = append(eff.globOps, globOp{g, true})
	}
	for _, g := range ps.Include.LoadConfiguration {
		eff.globOps = append(eff.globOps, globOp{g, true})
	}
	for _, g := range ps.Exclude.LoadConfiguration {
		eff.globOps = append(eff.globOps, globOp{g, false})
	}
	// dirs/install/services: additive include, subtractive exclude (exact match)
	eff.dirs = mergeList(eff.dirs, ps.MakeExtraDirs, ps.Include.MakeExtraDirs, ps.Exclude.MakeExtraDirs)
	eff.install = mergeList(eff.install, ps.Install, ps.Include.Install, ps.Exclude.Install)
	eff.services = mergeList(eff.services, ps.Services, ps.Include.Services, ps.Exclude.Services)
	return nil
}

// mergeList appends inline + include entries to xs, then drops every exclude entry.
func mergeList(xs, inline, include, exclude []string) []string {
	xs = append(append(xs, inline...), include...)
	if len(exclude) == 0 {
		return xs
	}
	return slices.DeleteFunc(xs, func(x string) bool { return slices.Contains(exclude, x) })
}

// isDetectable reports whether profile is both declared in the enum and defined.
func (r *Raw) isDetectable(profile string) bool {
	_, defined := r.profiles[profile]
	return defined && r.declared(profile)
}

// declared walks the profiles enum tree for the "<space>/<os>-<arch>" leaf.
func (r *Raw) declared(profile string) bool {
	space, leaf, ok := strings.Cut(profile, "/")
	if !ok {
		return false
	}
	m, ok := r.Profiles[space].(map[string]any)
	if !ok {
		return false
	}
	_, ok = m[leaf]
	return ok
}

// detectableLeaves lists the enum leaves that are also defined.
func (r *Raw) detectableLeaves() []string {
	var out []string
	for space, leaves := range r.Profiles {
		m, ok := leaves.(map[string]any)
		if !ok {
			continue
		}
		for leaf := range m {
			name := space + "/" + leaf
			if _, defined := r.profiles[name]; defined {
				out = append(out, name)
			}
		}
	}
	return slices.Sorted(slices.Values(out))
}

func sortedKeys(m map[string]any) []string {
	return slices.Sorted(maps.Keys(m))
}

// [<] 🤖🤖
