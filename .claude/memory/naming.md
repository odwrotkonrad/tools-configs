# Naming Convention

Executable assets are named `<kind>-<domain>-<descriptive-name>`, hyphens throughout.

- kind: `s-` script · `fn-` function · `a-` alias · `d-` launchd service
- domain: `rt` = system-owned (`root-ln/etc`, `root-ln/usr/local`, `root-cp`) · `ko` = user-owned (`root-ln/Users/ko`)
- scripts grouped under `root-ln/usr/local/scripts/{shell,installs,python}/`
- command overrides keep the bare name (`rm`, `prometheus`)
