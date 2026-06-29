package host

// [>] 🤖🤖

import (
	"bytes"
	"os"
	"strings"

	"configs/ci/go/packages/che/internal/render"
	"configs/ci/go/packages/che/internal/spec"
)

// filemodeDefault is the template install mode when the spec sets no chmod.
const filemodeDefault os.FileMode = 0600

// RenderTemplates renders each *.host.tpl in the resolved set onto the host.
// Glob-form items (no explicit dest) render to the derived live path; rich items
// fan out across their dests, inlining @-includes per RenderReferencedFiles.
func (h Host) RenderTemplates(templates []spec.FileItem) error {
	for _, item := range templates {
		if err := h.renderTemplate(item); err != nil {
			return err
		}
	}
	return nil
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

// placeFile backs up dest, installs body with spec perms (else default 0600, no chown).
func (h Host) placeFile(dest string, body []byte, item spec.FileItem) error {
	if err := h.fs.BackupBeforeOverwrite(dest, true); err != nil {
		return err
	}
	mode := filemodeDefault
	if m, ok := parseMode(item.Chmod); ok {
		mode = m
	}
	return h.fs.Install(dest, body, mode, ownerSpec(item))
}

// [<] 🤖🤖
