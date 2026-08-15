---
paths:
  - "**/git/**"
  - "**/.git/**"
---

## Git Config

### Files

```yml
profiles/git/:
  che.yml:  # git profile
  root/_home/.config/git/:
    config:
    ignore:
    commit-template:  # commit.template; type(scope): subject
```

Hooks via lefthook (`root/_home/.config/lefthook/lefthook.yml`)

### Documentation

`$ man`:

- `git`
- `git-config`: config keys, files, scopes, includes, color, alias
- `gitignore`: pattern format, precedence, negation, excludesfile
- `git-commit`: message, template, sign-off, gpgsign, scissors
- `gitattributes`: path attrs, diff, merge, filter, eol, export
- `git-log`: pretty formats, decorate, ranges, placeholders (`%h %ar %s`)
- `gitrevisions`: revision/range syntax (`A..B`, `@{u}`, `^`, `:/`)
- `git-push`: refspecs, default, autoSetupRemote, force-with-lease
- `gitmailmap`: map author/committer names and emails (mailmap.file)
- `gitcredentials`: credential.helper, url patterns, helper protocol
- `gitcli`: option parsing, `--`, conventions, exit codes
