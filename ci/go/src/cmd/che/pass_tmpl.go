package main

// [>] 🤖🤖🤖

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/template"

	"gopkg.in/yaml.v3"
)

// per-dest filemode/owner overrides (port of tmpl-render-onto-host:18-25).
const tmplFilemodeDefault os.FileMode = 0600

type tmplOverride struct {
	mode  os.FileMode
	owner string // "" -> no chown
}

func tmplOverrideFor(dest string) tmplOverride {
	switch dest {
	case "/etc/sudoers.d/configs":
		return tmplOverride{0440, "root:wheel"}
	case "/Library/LaunchAgents/d-user-gitlab-runner.plist":
		return tmplOverride{0644, "root:wheel"}
	default:
		return tmplOverride{tmplFilemodeDefault, ""}
	}
}

// passTmpl renders each *.host.auto.tmpl in the effective set onto the host.
// Engine: Go text/template (same engine gomplate wraps) with a FuncMap covering
// the namespaces the host templates use (env.Getenv, op).
func (a *app) passTmpl() error {
	cs, err := a.resolveConfigs()
	if err != nil {
		return err
	}
	for _, rel := range cs.templates {
		if err := a.renderTemplate(filepath.Join(a.root, rel)); err != nil {
			return err
		}
	}
	return nil
}

// funcMap reproduces the gomplate namespaces the host templates call.
func funcMap() template.FuncMap {
	return template.FuncMap{
		"env": func() envNS { return envNS{} },
		"op":  opRead,
	}
}

type envNS struct{}

func (envNS) Getenv(key string) string { return os.Getenv(key) }

// opRead shells to `op read --no-newline <ref>` (same as the gomplate op plugin).
func opRead(ref string) (string, error) {
	out, err := exec.Command("op", "read", "--no-newline", ref).Output()
	if err != nil {
		return "", fmt.Errorf("op read %q: %w", ref, err)
	}
	return string(out), nil
}

// renderTemplate handles both the no-frontmatter and the render-to frontmatter forms.
func (a *app) renderTemplate(tmplPath string) error {
	src, err := os.ReadFile(tmplPath)
	if err != nil {
		return err
	}
	if !bytes.HasPrefix(src, []byte("---\n")) {
		return a.renderPlain(tmplPath, src)
	}
	return a.renderFrontmatter(tmplPath, src)
}

// renderPlain: no frontmatter -> render to the live absolute path (HOME/ -> $HOME/).
func (a *app) renderPlain(tmplPath string, src []byte) error {
	rel := strings.TrimSuffix(filepathRelToRoot(a.root, tmplPath), tmplExt)
	dest := a.toDest(rel)
	body, err := a.execTemplate(tmplPath, src)
	if err != nil {
		return err
	}
	ov := tmplOverrideFor(dest)
	if err := a.backupBeforeOverwrite(dest, true); err != nil {
		return err
	}
	return a.placeRendered(dest, body, ov)
}

// renderFrontmatter: parse render-to (list of live paths), render the body once,
// fan out per output; AGENTS-style outputs inline @-includes.
func (a *app) renderFrontmatter(tmplPath string, src []byte) error {
	fm, body := splitFrontmatter(src)
	var meta struct {
		RenderTo flexList `yaml:"render-to"`
	}
	if err := yaml.Unmarshal(fm, &meta); err != nil {
		return fmt.Errorf("parse frontmatter %s: %w", tmplPath, err)
	}
	rendered, err := a.execTemplate(tmplPath, body)
	if err != nil {
		return err
	}
	for _, rt := range meta.RenderTo {
		dest := rt
		if strings.HasPrefix(dest, "~/") {
			dest = filepath.Join(a.home, dest[2:])
		}
		header := tmplHeader(dest, tmplPath)
		var out bytes.Buffer
		out.WriteString(header + "\n")
		if strings.Contains(filepath.Base(dest), "AGENTS") {
			out.Write(a.resolveAtIncludes(rendered))
		} else {
			out.Write(rendered)
		}
		ov := tmplOverrideFor(dest)
		if err := a.backupBeforeOverwrite(dest, true); err != nil {
			return err
		}
		if err := a.placeRendered(dest, out.Bytes(), ov); err != nil {
			return err
		}
	}
	return nil
}

// execTemplate runs the body through text/template with the host FuncMap.
func (a *app) execTemplate(name string, body []byte) ([]byte, error) {
	t, err := template.New(filepath.Base(name)).
		Option("missingkey=error").
		Funcs(funcMap()).
		Parse(string(body))
	if err != nil {
		return nil, fmt.Errorf("parse template %s: %w", name, err)
	}
	var buf bytes.Buffer
	if err := t.Execute(&buf, nil); err != nil {
		return nil, fmt.Errorf("render template %s: %w", name, err)
	}
	return buf.Bytes(), nil
}

// placeRendered writes body to a temp then installs it at dest with mode/owner,
// escalating priv iff dest is outside $HOME. Honors dry-run.
func (a *app) placeRendered(dest string, body []byte, ov tmplOverride) error {
	if a.dryRun {
		a.logMsg("render", dest)
		return nil
	}
	tmp, err := os.CreateTemp("", "che-tmpl-*")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())
	if _, err := tmp.Write(body); err != nil {
		return err
	}
	tmp.Close()

	argv := []string{"install", "-m", modeArg(ov.mode)}
	if ov.owner != "" {
		argv = append(argv, "-o", strings.SplitN(ov.owner, ":", 2)[0],
			"-g", strings.SplitN(ov.owner, ":", 2)[1])
	}
	argv = append(argv, tmp.Name(), dest)
	if err := a.priv(dest, argv...); err != nil {
		return err
	}
	a.logMsg("render", dest)
	return nil
}

// resolveAtIncludes inlines '@path' lines as the contents of repoRoot/<path>;
// '~/' -> root/HOME/. Port of fn-tmpl-resolve-at-includes.
func (a *app) resolveAtIncludes(body []byte) []byte {
	var out bytes.Buffer
	sc := bufio.NewScanner(bytes.NewReader(body))
	sc.Buffer(make([]byte, 0, 64*1024), 4*1024*1024)
	for sc.Scan() {
		line := sc.Text()
		if isAtInclude(line) {
			path := strings.TrimPrefix(line, "@")
			if strings.HasPrefix(path, "~/") {
				path = "root/HOME/" + path[2:]
			}
			content, err := os.ReadFile(filepath.Join(a.repoRoot, path))
			if err == nil {
				out.Write(bytes.TrimRight(content, "\n"))
				out.WriteByte('\n')
				continue
			}
		}
		out.WriteString(line + "\n")
	}
	return out.Bytes()
}

// isAtInclude: a line that is exactly '@<no-space>' with no whitespace.
func isAtInclude(line string) bool {
	if !strings.HasPrefix(line, "@") || len(line) < 2 {
		return false
	}
	return !strings.ContainsAny(line, " \t")
}

// tmplHeader: autogen comment by extension. Port of fn-tmpl-header.
func tmplHeader(out, tmplPath string) string {
	if strings.HasSuffix(out, ".md") {
		return fmt.Sprintf("<!-- autogenerated using %s -->", tmplPath)
	}
	return fmt.Sprintf("# autogenerated using %s", tmplPath)
}

// splitFrontmatter returns (frontmatterYAML, body) from a '---\n...\n---\n' doc.
func splitFrontmatter(src []byte) (fm, body []byte) {
	rest := src[len("---\n"):]
	if i := bytes.Index(rest, []byte("\n---\n")); i >= 0 {
		return rest[:i+1], rest[i+len("\n---\n"):]
	}
	if i := bytes.Index(rest, []byte("\n---")); i >= 0 {
		return rest[:i+1], rest[i+len("\n---"):]
	}
	return nil, src
}

// flexList unmarshals a YAML scalar or sequence into []string (render-to flatten).
type flexList []string

func (f *flexList) UnmarshalYAML(value *yaml.Node) error {
	if value.Kind == yaml.ScalarNode {
		*f = flexList{value.Value}
		return nil
	}
	var xs []string
	if err := value.Decode(&xs); err != nil {
		return err
	}
	*f = xs
	return nil
}

func filepathRelToRoot(root, p string) string {
	rel, err := filepath.Rel(root, p)
	if err != nil {
		return p
	}
	return rel
}

// [<] 🤖🤖🤖
