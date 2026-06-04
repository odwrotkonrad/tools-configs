# Naming Convention

Executable assets are named `<kind>-<domain>-<descriptive-name>`, hyphens throughout.

- kind: `s-` script · `fn-` function · `a-` alias · `d-` launchd service
- domain: `rt` = system-owned (`root/etc`, `root/usr/local`, `_root`) · `ko` = user-owned (`root/Users/ko`)
- scripts grouped under `root/usr/local/scripts/{shell,installs,python}/`
- command overrides keep the bare name (`rm`, `prometheus`)
