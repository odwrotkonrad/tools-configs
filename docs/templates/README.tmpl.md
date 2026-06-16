## **Config**uration file**s**

{{ load('../prose/description/human.md').content }}
{{ load('../prose/purpose.human.md').content }}
{% set f = load('../data/tools-inventory-index.yml') %}
## {{ f.frontmatter.title }}

{{ f.frontmatter.description }}

```yaml
{{ f.content }}```

{% for uri, desc in f.frontmatter.references.items() %}
- [{{ uri }}]({{ uri }}) - {{ desc }}
{% endfor %}

## Observability

### Claude Code

Dashboard for Claude Code usage, cost and token metrics.

![Claude Code dashboard](docs/assets/images/grafana-claude-code-dashboard-pt-1.png)

[recording](docs/assets/recordings/grafana-cc-dashboard.gif) · [more](docs/assets/images/grafana-claude-code-dashboard-pt-2.png)

### Host System

Dashboard for host CPU, memory, disk and network metrics.

![Host system dashboard](docs/assets/images/grafana-host-dashboard-pt-1.png)

[recording](docs/assets/recordings/grafana-host-dashboard.gif) · [more](docs/assets/images/grafana-host-dashboard-pt-2.png)

## ☢️ Danger Zone - Loading Configs ☢️

Loading configuration directly modifies the OS, including system, non-user files. If you find anything of interest, prefer copying these pieces into your own config.

[Loading Configs](docs/prose/loading-configuration.md)
