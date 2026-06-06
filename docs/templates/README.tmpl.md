## **Config**uration file**s**

{{ load('../readme/purpose.md').content }}
{% set f = load('../data/tools-inventory-index.yml') %}
## {{ f.frontmatter.title }}

{{ f.frontmatter.description }}

```yaml
{{ f.content }}```

{% for uri, desc in f.frontmatter.references.items() %}
- [{{ uri }}]({{ uri }}) — {{ desc }}
{% endfor %}

## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](docs/readme/images/grafana-claude-code-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-cc-dashboard.gif) · [more](docs/readme/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](docs/readme/images/grafana-host-dashboard-pt-1.png)

[recording](docs/readme/recordings/grafana-host-dashboard.gif) · [more](docs/readme/images/grafana-host-dashboard-pt-2.png)
