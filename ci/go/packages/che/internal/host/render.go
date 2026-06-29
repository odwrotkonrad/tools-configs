package host

// [>] 🤖🤖

import (
	"bytes"
	"os"
	"strings"

	"configs/ci/go/packages/che/internal/render"
	"configs/ci/go/packages/che/internal/spec"
)

// RenderTemplates renders each *.host.tpl in the resolved set onto the host.
// Glob-form items (no explicit dest) render to the derived live path; rich items
// fan out across their dests, inlining @-includes per RenderReferencedFiles.
func (h Host) RenderTemplates(templates []spec.FileItem) error {
	var dests []string
	for _, item := range templates {
		dests = append(dests, h.templateDests(item)...)
	}
	if err := h.archiveBefore("render", dests); err != nil {
		return err
	}
	for _, item := range templates {
		if err := h.renderTemplate(item); err != nil {
			return err
		}
	}
	return nil
}

// templateDests returns an item's live dests: derived path (glob-form, no
// explicit dest) else its expanded dests.
func (h Host) templateDests(item spec.FileItem) []string {
	if len(item.Dests) == 0 {
		return []string{h.ToDest(strings.TrimSuffix(item.Rel, spec.TmplExt))}
	}
	out := make([]string, len(item.Dests))
	for i, d := range item.Dests {
		out[i] = h.expandHome(d.Path)
	}
	return out
}

func (h Host) renderTemplate(item spec.FileItem) error {
	tmplPath := h.Src(item.Rel)
	src, err := os.ReadFile(tmplPath)
	if err != nil {
		return err
	}
	body, err := render.Exec(tmplPath, src)
	if err != nil {
		return err
	}
	if len(item.Dests) == 0 {
		rel := strings.TrimSuffix(item.Rel, spec.TmplExt)
		return h.placeFile(h.ToDest(rel), body, item)
	}
	for _, d := range item.Dests {
		dest := h.expandHome(d.Path)
		var out bytes.Buffer
		out.WriteString(render.Header(dest, tmplPath))
		out.WriteByte('\n')
		if d.RenderReferencedFiles {
			out.Write(render.ResolveAtIncludes(h.RepoRoot, body))
		} else {
			out.Write(body)
		}
		if err := h.placeFile(dest, out.Bytes(), item); err != nil {
			return err
		}
	}
	return nil
}

// placeFile installs body with spec perms (mode 0 -> install default, no chown).
func (h Host) placeFile(dest string, body []byte, item spec.FileItem) error {
	mode, _ := parseMode(item.Chmod)
	return h.fs.Install(dest, body, mode, ownerSpec(item))
}

// [<] 🤖🤖
