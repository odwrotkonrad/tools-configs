package host

// [>] 🤖🤖

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"

	"configs/ci/go/packages/che/internal/render"
)

// per-dest filemode/owner overrides.
const filemodeDefault os.FileMode = 0600

type override struct {
	mode  os.FileMode
	owner string // "" -> no chown
}

func overrideFor(dest string) override {
	switch dest {
	case "/etc/sudoers.d/configs":
		return override{0440, "root:wheel"}
	case "/Library/LaunchAgents/gitlab-runner.plist":
		return override{0644, "root:wheel"}
	default:
		return override{filemodeDefault, ""}
	}
}

// RenderTemplates renders each *.host.tpl in the resolved set onto the host.
func (h Host) RenderTemplates(templateRels []string) error {
	for _, rel := range templateRels {
		if err := h.renderTemplate(h.Src(rel)); err != nil {
			return err
		}
	}
	return nil
}

// renderTemplate: dispatch on frontmatter presence.
func (h Host) renderTemplate(tmplPath string) error {
	src, err := os.ReadFile(tmplPath)
	if err != nil {
		return err
	}
	if !render.HasFrontmatter(src) {
		return h.renderPlain(tmplPath, src)
	}
	return h.renderFrontmatter(tmplPath, src)
}

// placeFile: back up dest, install body with per-dest override.
func (h Host) placeFile(dest string, body []byte) error {
	if err := h.fs.BackupBeforeOverwrite(dest, true); err != nil {
		return err
	}
	ov := overrideFor(dest)
	return h.fs.Install(dest, body, ov.mode, ov.owner)
}

// renderPlain: no frontmatter -> render to the live absolute path (HOME/ -> $HOME/).
func (h Host) renderPlain(tmplPath string, src []byte) error {
	rel := strings.TrimSuffix(h.relToRoot(tmplPath), ".host.tpl")
	body, err := render.Exec(tmplPath, src)
	if err != nil {
		return err
	}
	return h.placeFile(h.ToDest(rel), body)
}

// renderFrontmatter: render body once, fan out per render-to dest. AGENTS dests inline @-includes.
func (h Host) renderFrontmatter(tmplPath string, src []byte) error {
	fm, body := render.SplitFrontmatter(src)
	var meta struct {
		RenderTo render.FlexList `yaml:"render-to"`
	}
	if err := yaml.Unmarshal(fm, &meta); err != nil {
		return fmt.Errorf("parse frontmatter %s: %w", tmplPath, err)
	}
	rendered, err := render.Exec(tmplPath, body)
	if err != nil {
		return err
	}
	for _, dest := range meta.RenderTo {
		if rest, ok := strings.CutPrefix(dest, "~/"); ok {
			dest = filepath.Join(h.Home, rest)
		}
		var out bytes.Buffer
		out.WriteString(render.Header(dest, tmplPath))
		out.WriteByte('\n')
		if strings.Contains(filepath.Base(dest), "AGENTS") {
			out.Write(render.ResolveAtIncludes(h.RepoRoot, rendered))
		} else {
			out.Write(rendered)
		}
		if err := h.placeFile(dest, out.Bytes()); err != nil {
			return err
		}
	}
	return nil
}

func (h Host) relToRoot(p string) string {
	rel, err := filepath.Rel(h.Root, p)
	if err != nil {
		return p
	}
	return rel
}

// [<] 🤖🤖
