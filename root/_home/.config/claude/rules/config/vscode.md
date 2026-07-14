---
paths:
  - "**/Library/Application Support/Code/**"
---

## VS Code Config

### Files
```
Library/Application Support/Code/User/
  .exported/                  # exported VS Code defaults; source of commands/settings
    defaultKeybindings.jsonc
    defaultSettings.jsonc
  keybindings.json            # active keybindings
  settings.json               # active settings
```

### Documentation

Read `.exported/` for available commands and settings.

Extension docs: `/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/<ext>/package.json` (`<ext>` = git, github, …).

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
