## **Config**uration file**s**

{{ load('../readme/purpose.md').content }}
{% set f = load('../tools-inventory-index.yml') %}
## {{ f.frontmatter.title }}

{{ f.frontmatter.description }}

```yaml
{{ f.content }}```

{% for uri, desc in f.frontmatter.references.items() %}
- [{{ uri }}]({{ uri }}) — {{ desc }}
{% endfor %}
