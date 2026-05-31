---
paths:
  - "**/Library/Application Support/Code/**"
---

## VS Code Config

### Files
```
Library/Application Support/Code/User/
├── .exported
│   ├── defaultKeybindings.jsonc
│   └── defaultSettings.jsonc
├── keybindings.json                       # actual keybindings configuration
├── settings.json                          # actual settings
└── unmodified-settings.jsonc              # unmodified settings
```

### Documentation

Use these files as the source of available commands / settings; these are exported files from VS Code.
```sh
├── .exported
│   ├── defaultKeybindings.jsonc
│   └── defaultSettings.jsonc
```

Extensions documentation is located at:

`/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/<ext>/package.json`

where <ext> is git, github, etc.

```jsonc
// <ext>/package.json structure
{
  "contributes": {
    "commands": [],            // command ids + titles; handles for keybindings/menus
    "continueEditSession": [], // entries for "Continue Working On…" flow
    "keybindings": [],         // default key bindings -> command mappings
    "menus": {},               // command placements keyed by menu location id
    "submenus": [],            // nested submenus referenced from `menus`
    "configuration": [],       // settings the ext defines (JSON-schema properties)
    "configurationDefaults": {} // default overrides for other settings
  }
}
```
