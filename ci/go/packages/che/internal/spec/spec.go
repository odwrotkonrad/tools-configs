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

// Raw mirrors che.yml. Profiles is the enum tree (declared detectable leaves);
// the remaining top-level keys hold defined blocks: leaf profiles
// ("bare-metal/mac-os-aarch64", ...) and included profiles ("base-cli", ...).
type Raw struct {
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
	Services          []string       `yaml:"services"`
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
	Services          []string `yaml:"services"`
}

// effective is the detected profile's composed selection before file classification.
// globOps is an ordered op list (include +/exclude −) in composition order; a file
// is selected iff the LAST op matching it is an include. Dirs/Install/Services are
// exact-subtracted as they merge.
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

// Resolved is the classified, repo-relative selection the host/repo passes consume.
// Links/Copies/Templates/Dirs are under root/; Installs/Services are spec lists.
type Resolved struct {
	Links     []string // link pass: regular files minus templates/copies/.gitkeep
	Copies    []string // copy pass: *.host.cp
	Templates []string // render pass: *.host.tpl
	Dirs      []string // every ancestor dir of links+copies+templates, plus make-extra-dirs
	ExtraDirs []string // make-extra-dirs only (live dest entries)
	Services  []string // service names (compositional)
	Installs  []string // install unit entries in spec order
}

// Load parses che.yml: the `profiles:` enum, plus every other top-level key as a
// defined block (leaf profiles and included profiles alike).
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

// Resolve validates the detected profile is defined, composes its include-profiles
// and inline sections, then classifies the git-tracked files under root into
// Links/Copies/Templates/Dirs. Output is repo-relative; host/repo map to dest.
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
	// brace-expand all path/glob lists (zsh-style {a,b}); ops keep their order
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

// classify expands the load-configuration ops against the git-tracked files under
// root and buckets them into Links/Copies/Templates + their ancestor Dirs.
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
	slices.Sort(res.Dirs) // lexical -> parents before children
	return nil
}

// selected applies the ordered load-configuration ops: a file is selected iff the
// LAST op whose glob matches it is an include. Unmatched files are not selected.
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

// mergeInto composes name into eff: its include-profiles (depth-first, in order),
// its inline sections, then its own include (additive) and exclude (subtractive
// for dirs/install/services; exclude globs accumulate for file-time filtering).
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
