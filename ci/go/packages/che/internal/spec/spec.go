package spec

// [>] 🤖🤖

import (
	"fmt"
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
// top-level keys are defined blocks: leaf profiles and mixin profiles.
type Raw struct {
	Profiles map[string]any         `yaml:"profiles"`
	profiles map[string]profileSpec // every defined block, keyed by name
}

// profileSpec is one block: mixin-profiles composed in order, then include
// (additive) and exclude (subtractive glob filter, applied last, wins).
type profileSpec struct {
	MixinProfiles []string   `yaml:"mixin-profiles"`
	Include       includeSet `yaml:"include"`
	Exclude       excludeSet `yaml:"exclude"`
}

// includeSet is the additive payload: link globs, copy/template/mkdirs entries
// (glob-string OR rich object), install globs, service names.
type includeSet struct {
	Link     []string    `yaml:"link"`
	Copy     []copyEntry `yaml:"copy"`
	Template []tmplEntry `yaml:"template"`
	Mkdirs   []dirEntry  `yaml:"mkdirs"`
	Install  []string    `yaml:"install"`
	Services []string    `yaml:"services"`
}

// excludeSet is the subtractive payload: every key a flat glob-string list, a
// match drops the item.
type excludeSet struct {
	Link     []string `yaml:"link"`
	Copy     []string `yaml:"copy"`
	Template []string `yaml:"template"`
	Mkdirs   []string `yaml:"mkdirs"`
	Install  []string `yaml:"install"`
	Services []string `yaml:"services"`
}

// destOpt is a parsed dest entry: a path plus per-dest options.
type destOpt struct {
	Path                  string `yaml:"path"`
	RenderReferencedFiles bool   `yaml:"render-referenced-files"`
}

// copyEntry / tmplEntry / dirEntry are a YAML union: a bare glob string, or a
// rich object carrying explicit dest(s) + perms. glob reports the glob form.
type copyEntry struct {
	glob       string
	Source     string    `yaml:"source"`
	Dest       []destOpt `yaml:"dest"`
	Owner      string    `yaml:"owner"`
	OwnerGroup string    `yaml:"owner-group"`
	Chmod      string    `yaml:"chmod"`
}

type tmplEntry copyEntry
type dirEntry copyEntry

func unmarshalEntry(value *yaml.Node, glob *string, rich any) error {
	if value.Kind == yaml.ScalarNode {
		*glob = value.Value
		return nil
	}
	return value.Decode(rich)
}

func (e *copyEntry) UnmarshalYAML(value *yaml.Node) error {
	type alias copyEntry
	return unmarshalEntry(value, &e.glob, (*alias)(e))
}
func (e *tmplEntry) UnmarshalYAML(value *yaml.Node) error {
	type alias tmplEntry
	return unmarshalEntry(value, &e.glob, (*alias)(e))
}
func (e *dirEntry) UnmarshalYAML(value *yaml.Node) error {
	type alias dirEntry
	return unmarshalEntry(value, &e.glob, (*alias)(e))
}

// FileItem is one resolved file: repo-relative source (under root/), explicit
// dests (nil -> derived in host), optional perms.
type FileItem struct {
	Rel        string
	Dests      []DestSpec
	Owner      string
	OwnerGroup string
	Chmod      string
}

// DestSpec is one resolved dest path plus per-dest template option.
type DestSpec struct {
	Path                  string
	RenderReferencedFiles bool
}

// Resolved is the classified, repo-relative selection the passes consume.
type Resolved struct {
	Links     []FileItem // link pass: regular files minus templates/copies/.gitkeep
	Copies    []FileItem // copy pass: *.host.cp
	Templates []FileItem // render pass: *.host.tpl
	Dirs      []string   // every ancestor dir of links+copies+templates, plus mkdirs
	ExtraDirs []FileItem // mkdirs only (live dest entries), one per path, carrying perms
	Services  []string   // service names
	Installs  []string   // install unit entries in spec order
}

// globPerms carries the perms an include glob confers on its classified files.
type globPerms struct {
	owner, ownerGroup, chmod string
}

// effective is the composed additive selection before classification + exclude.
type effective struct {
	linkGlobs []string             // link-pass globs (repo-relative under root/)
	copyGlobs []string             // copy-pass globs
	tmplGlobs []string             // template-pass globs
	perms     map[string]globPerms // glob -> perms (copy/template glob forms)
	richCopy  []FileItem           // rich-form copy entries
	richTmpl  []FileItem           // rich-form template entries
	dirs      []FileItem           // mkdirs (glob + rich), one FileItem per entry, path in Dests
	install   []string             // install unit paths (order = run order)
	services  []string             // service names
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

// Resolve validates the profile is defined, composes its mixin-profiles and
// includes, classifies git-tracked files, then applies excludes as a final glob
// filter. Output is repo-relative.
func (r *Raw) Resolve(profile, root string) (Resolved, error) {
	if !r.isDetectable(profile) {
		return Resolved{}, fmt.Errorf(
			"detected profile %q is not defined in che.yml (defined: %v)",
			profile, r.detectableLeaves())
	}
	eff := effective{perms: map[string]globPerms{}}
	if err := r.mergeInto(&eff, profile, nil); err != nil {
		return Resolved{}, err
	}
	res := Resolved{
		ExtraDirs: expandDirs(eff.dirs),
		Installs:  fsutil.ExpandAll(eff.install),
		Services:  fsutil.ExpandAll(eff.services),
		Copies:    eff.richCopy,
		Templates: eff.richTmpl,
	}
	if err := classify(root, eff, &res); err != nil {
		return Resolved{}, err
	}
	r.applyExcludes(profile, &res)
	return res, nil
}

// classify applies the glob-form ops to git-tracked files under root, bucketing
// them into Links/Copies/Templates plus ancestor Dirs. Glob copy/template files
// inherit the matching glob's perms.
func classify(root string, eff effective, res *Resolved) error {
	tracked, err := fsutil.TrackedFiles(root)
	if err != nil {
		return err
	}
	links := fsutil.ExpandAll(eff.linkGlobs)
	copies := fsutil.ExpandAll(eff.copyGlobs)
	tmpls := fsutil.ExpandAll(eff.tmplGlobs)
	rich := richRels(eff) // rich entries win: skip their glob twins
	for _, rel := range tracked {
		if rich[rel] {
			continue
		}
		switch {
		case matchAny(tmpls, rel) && strings.HasSuffix(rel, TmplExt):
			res.Templates = append(res.Templates, fileItem(rel, eff, tmpls))
		case matchAny(copies, rel) && strings.HasSuffix(rel, CpExt):
			res.Copies = append(res.Copies, fileItem(rel, eff, copies))
		case filepath.Base(rel) == ".gitkeep":
			// excluded from every pass
		case matchAny(links, rel):
			res.Links = append(res.Links, FileItem{Rel: rel})
		}
	}
	collectDirs(res)
	return nil
}

// richRels is the set of source rels claimed by rich copy/template entries.
func richRels(eff effective) map[string]bool {
	m := map[string]bool{}
	for _, it := range eff.richCopy {
		m[it.Rel] = true
	}
	for _, it := range eff.richTmpl {
		m[it.Rel] = true
	}
	return m
}

// fileItem builds a glob-derived FileItem (no explicit dest), inheriting the
// perms of the last matching glob.
func fileItem(rel string, eff effective, globs []string) FileItem {
	fi := FileItem{Rel: rel}
	for _, g := range globs {
		if fsutil.MatchGlob(strings.TrimSuffix(g, "/"), rel) {
			if p, ok := eff.perms[g]; ok {
				fi.Owner, fi.OwnerGroup, fi.Chmod = p.owner, p.ownerGroup, p.chmod
			}
		}
	}
	return fi
}

// collectDirs derives every ancestor dir of the file items into res.Dirs.
func collectDirs(res *Resolved) {
	dirSeen := map[string]bool{}
	add := func(items []FileItem) {
		for _, it := range items {
			for d := filepath.Dir(it.Rel); d != "." && !dirSeen[d]; d = filepath.Dir(d) {
				dirSeen[d] = true
				res.Dirs = append(res.Dirs, d)
			}
		}
	}
	add(res.Links)
	add(res.Copies)
	add(res.Templates)
	slices.SortFunc(res.Links, byRel)
	slices.SortFunc(res.Copies, byRel)
	slices.SortFunc(res.Templates, byRel)
	slices.Sort(res.Dirs) // lexical, parents before children
}

func byRel(a, b FileItem) int { return strings.Compare(a.Rel, b.Rel) }

func matchAny(globs []string, rel string) bool {
	for _, g := range globs {
		if fsutil.MatchGlob(strings.TrimSuffix(g, "/"), rel) {
			return true
		}
	}
	return false
}

// applyExcludes drops items matching any exclude glob across all keys. Excludes
// win over everything, including rich include entries.
func (r *Raw) applyExcludes(profile string, res *Resolved) {
	var ex excludeSet
	r.collectExcludes(profile, nil, &ex)

	link := fsutil.ExpandAll(ex.Link)
	copyG := fsutil.ExpandAll(ex.Copy)
	tmplG := fsutil.ExpandAll(ex.Template)
	dirG := fsutil.ExpandAll(ex.Mkdirs)
	instG := fsutil.ExpandAll(ex.Install)
	svcG := fsutil.ExpandAll(ex.Services)

	res.Links = dropFiles(res.Links, link)
	res.Copies = dropFiles(res.Copies, copyG)
	res.Templates = dropFiles(res.Templates, tmplG)
	res.ExtraDirs = dropFiles(res.ExtraDirs, dirG)
	res.Installs = dropStrings(res.Installs, instG)
	res.Services = dropStrings(res.Services, svcG)

	res.Dirs = nil
	collectDirs(res)
	res.Dirs = dropStrings(res.Dirs, dirG)
}

// collectExcludes accumulates every mixin's exclude globs (composition order).
func (r *Raw) collectExcludes(name string, seen []string, ex *excludeSet) {
	if slices.Contains(seen, name) {
		return
	}
	ps, ok := r.profiles[name]
	if !ok {
		return
	}
	child := append(slices.Clone(seen), name)
	for _, m := range ps.MixinProfiles {
		r.collectExcludes(m, child, ex)
	}
	ex.Link = append(ex.Link, ps.Exclude.Link...)
	ex.Copy = append(ex.Copy, ps.Exclude.Copy...)
	ex.Template = append(ex.Template, ps.Exclude.Template...)
	ex.Mkdirs = append(ex.Mkdirs, ps.Exclude.Mkdirs...)
	ex.Install = append(ex.Install, ps.Exclude.Install...)
	ex.Services = append(ex.Services, ps.Exclude.Services...)
}

// dropFiles drops any FileItem whose rel or any dest matches an exclude glob.
func dropFiles(items []FileItem, globs []string) []FileItem {
	if len(globs) == 0 {
		return items
	}
	return slices.DeleteFunc(items, func(it FileItem) bool {
		if matchAny(globs, it.Rel) {
			return true
		}
		for _, d := range it.Dests {
			if matchAny(globs, d.Path) {
				return true
			}
		}
		return false
	})
}

// dropStrings drops any entry matching an exclude glob.
func dropStrings(xs, globs []string) []string {
	if len(globs) == 0 {
		return xs
	}
	return slices.DeleteFunc(xs, func(x string) bool { return matchAny(globs, x) })
}

// mergeInto composes name into eff: mixin-profiles depth-first, then this
// profile's include sections (additive). Excludes are handled separately
// (applyExcludes). seen catches cycles.
func (r *Raw) mergeInto(eff *effective, name string, seen []string) error {
	if slices.Contains(seen, name) {
		return fmt.Errorf("mixin-profiles cycle: %v -> %s", seen, name)
	}
	ps, ok := r.profiles[name]
	if !ok {
		return fmt.Errorf("mixin-profiles names undefined profile %q (from %v)", name, seen)
	}
	child := append(slices.Clone(seen), name)
	for _, m := range ps.MixinProfiles {
		if err := r.mergeInto(eff, m, child); err != nil {
			return err
		}
	}
	in := ps.Include
	eff.linkGlobs = append(eff.linkGlobs, in.Link...)
	addEntries(eff, copyKind, in.Copy)
	addEntries(eff, tmplKind, asCopy(in.Template))
	addDirs(eff, in.Mkdirs)
	eff.install = append(eff.install, in.Install...)
	eff.services = append(eff.services, in.Services...)
	return nil
}

type kind int

const (
	copyKind kind = iota
	tmplKind
)

func asCopy(ts []tmplEntry) []copyEntry {
	out := make([]copyEntry, len(ts))
	for i, t := range ts {
		out[i] = copyEntry(t)
	}
	return out
}

// addEntries routes copy/template entries: glob form -> glob list (+perms),
// rich form -> FileItem.
func addEntries(eff *effective, k kind, entries []copyEntry) {
	for _, e := range entries {
		if e.glob != "" {
			if k == tmplKind {
				eff.tmplGlobs = append(eff.tmplGlobs, e.glob)
			} else {
				eff.copyGlobs = append(eff.copyGlobs, e.glob)
			}
			if e.Owner != "" || e.OwnerGroup != "" || e.Chmod != "" {
				eff.perms[e.glob] = globPerms{e.Owner, e.OwnerGroup, e.Chmod}
			}
			continue
		}
		fi := FileItem{
			Rel:        e.Source,
			Dests:      dests(e.Dest),
			Owner:      e.Owner,
			OwnerGroup: e.OwnerGroup,
			Chmod:      e.Chmod,
		}
		if k == tmplKind {
			eff.richTmpl = append(eff.richTmpl, fi)
		} else {
			eff.richCopy = append(eff.richCopy, fi)
		}
	}
}

// addDirs routes mkdirs entries: glob form -> FileItem with one dest, no perms;
// rich form -> FileItem with its dests + perms.
func addDirs(eff *effective, entries []dirEntry) {
	for _, e := range entries {
		if e.glob != "" {
			eff.dirs = append(eff.dirs, FileItem{Dests: []DestSpec{{Path: e.glob}}})
			continue
		}
		eff.dirs = append(eff.dirs, FileItem{
			Dests:      dests(e.Dest),
			Owner:      e.Owner,
			OwnerGroup: e.OwnerGroup,
			Chmod:      e.Chmod,
		})
	}
}

// expandDirs brace-expands each dir entry's dest paths into one FileItem per
// resulting path, carrying the entry's perms. Path lives in Dests[0].
func expandDirs(entries []FileItem) []FileItem {
	var out []FileItem
	for _, e := range entries {
		for _, d := range e.Dests {
			for _, p := range fsutil.ExpandBraces(d.Path) {
				out = append(out, FileItem{
					Dests:      []DestSpec{{Path: p}},
					Owner:      e.Owner,
					OwnerGroup: e.OwnerGroup,
					Chmod:      e.Chmod,
				})
			}
		}
	}
	return out
}

func dests(opts []destOpt) []DestSpec {
	if len(opts) == 0 {
		return nil
	}
	out := make([]DestSpec, len(opts))
	for i, o := range opts {
		out[i] = DestSpec{Path: o.Path, RenderReferencedFiles: o.RenderReferencedFiles}
	}
	return out
}

// isDetectable reports whether profile is both declared in the enum and defined.
func (r *Raw) isDetectable(profile string) bool {
	_, defined := r.profiles[profile]
	return defined && r.declared(profile)
}

// declared walks the profiles enum tree for the "<space>/<os>" leaf.
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

// [<] 🤖🤖
