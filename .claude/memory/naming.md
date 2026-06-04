# Naming Convention

Executable assets are named `<kind>-<domain>-<descriptive-name>`, hyphens throughout.

- kind: `s-` script · `fn-` function · `a-` alias · `d-` launchd service
- domain: `rt` = system-owned (`root_ln/etc`, `root_ln/usr/local`, `root_cp`) · `ko` = user-owned (`root_ln/Users/ko`)
- scripts grouped under `root_ln/usr/local/scripts/{shell,installs,python}/`
- command overrides keep the bare name (`rm`, `prometheus`)
