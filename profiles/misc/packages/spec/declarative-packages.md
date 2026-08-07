# Feature: Declarative Packages, One Yaml + fn-install

<!-- [>] 🤖🤖 -->

`~/.config/packages/packages.yml` maps each canonical package name to its managers; `fn-install <pkg>...` resolves and installs. Install scripts stay one `fn-install` line.

Scenario: a config author declares every package once, under one canonical name
  Status: implemented
  Given a package entry `pkg: [npm, brew, apt]` in packages.yml
  When any install script runs `fn-install pkg`
  Then the first manager applicable on this host installs it (brew binds to macos, apt to linux, npm to wherever npm is present)
  And the managers are tried in the entry's listed order
  And a package shipping a CLI is named after its CLI program (`claude`, `tsc`, `sqlite3`), so presence checks and /usr/local/bin install names stay honest

Scenario: a package keeps one canonical name even where a manager names it differently
  Status: implemented
  Given an entry item written as an object, `fd: [brew, {apt: fd-find}]`
  When `fn-install fd` resolves on linux
  Then apt installs `fd-find`, while the caller only ever says `fd`

Scenario: an install script is one line, no per-OS branching
  Status: implemented
  When a profile needs a tool (git, tmux, kind, glab, ...)
  Then its install script is `fn-install <canonical-name>`, nothing else

Scenario: a package with no manager for this host skips cleanly instead of failing
  Status: implemented
  Given an entry listing only managers foreign to this host (e.g. `ruby-dev: [{apt: ruby-dev}]` on macos)
  When `fn-install ruby-dev` runs
  Then it logs `skip ruby-dev: no applicable manager` and exits zero

Scenario: an unknown package name fails loudly, pointing at the yaml
  Status: implemented
  When `fn-install nosuchpkg` finds no entry
  Then it errors with `unknown package: nosuchpkg (add it to <path>)`

Scenario: a prebuilt binary installs declaratively: url, sha256, done
  Status: implemented
  Given a `- binary:` entry carrying version, a url templated with {version} {os} {arch} {arch_x}, optional `bin` archive member, and sha256 per os-arch
  When fn-install picks it (no earlier manager applied and a sha256 exists for this os-arch)
  Then the asset downloads, its sha256 verifies or the install aborts
  And a tar asset extracts the `bin` member, a bare asset installs as-is
  And the result lands executable at /usr/local/bin/<canonical-name>

Scenario: one call installs a manager and then packages through it
  Status: implemented
  Given `fn-install node npm typescript` on a fresh linux host
  When npm arrives via the apt batch
  Then a later resolution round (after rehash) installs typescript through the fresh npm
  And packages still unresolved after a fruitless round log as skipped

Scenario: re-running any install script changes nothing
  Status: implemented
  Given all requested packages already present
  When fn-install runs again
  Then each manager reports `already installed`, no install command fires
  And a command already on PATH under an npm package's bin name (e.g. corepack's pnpm shim) counts as installed
<!-- [<] 🤖🤖 -->
