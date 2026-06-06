{% set f = load('frontmatter.data.yml') %}
# {{ f.frontmatter.title }}

{{ f.frontmatter.description }}

```yaml
{{ f.content }}```

{% for uri, desc in f.frontmatter.references.items() %}
- {{ uri }}: {{ desc }}
{% endfor %}
