---
render-to: README.md
---
{{- $inv := renderWithFrontmatter "assets/data/tools-inventory-index.yml" | data.YAML -}}
## **Config**uration file**s**

{{ file.Read "assets/docs-human/description.md" }}
{{ file.Read "assets/docs-human/purpose.md" }}
## {{ $inv.frontmatter.title }}

{{ $inv.frontmatter.description }}

```yaml
{{ $inv.body }}```

{{ range $uri, $desc := $inv.frontmatter.references -}}
- [{{ $uri }}]({{ $uri }}) - {{ $desc }}
{{ end }}
## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](assets/images/grafana-claude-code-dashboard-pt-1.png)

[recording](assets/recordings/grafana-cc-dashboard.gif) · [more](assets/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](assets/images/grafana-host-dashboard-pt-1.png)

[recording](assets/recordings/grafana-host-dashboard.gif) · [more](assets/images/grafana-host-dashboard-pt-2.png)

## ☢️ Danger Zone - Loading Configs ☢️

Loading configuration directly modifies the OS, including system, non-user files. If you find anything of interest, prefer copying these pieces into your own config.

[Loading Configs](assets/docs-human/loading-configuration.md)
