## Feature zsh_completions_dirs

### As a shell user

I want directory completion candidates
	to show directories from
		3 levels: PWD, PWD+1, and PWD+2
		the directory stack contents

  to be shown in order:
    1. PWD
    2. PWD+1
    3. PWD+2
    4. ../* (PWD siblings, PWD itself excluded)
    5. ../*/* (siblings' children, PWD's own children excluded)
    6. ../../* (grandparent children, parent dir excluded)
    7. Directory stack contents
    8. Directory stack contents PWD+1
    9. Directory stack contents PWD+2
    10. Named dirs (hash -d), shown last as ~name

    and within each segment, I want this specific ordering:
      non-hidden directories, sorted by the number of items inside
      hidden directories, sorted by the number of items inside
      configurable deprioritized directories (e.g., .git, node_modules, test)

  to allow searching for directories
    in a fuzzy, path-segment-aware, and restricted way (e.g., refs matches .git/refs, but not re/fs)
      with segment order preserved and the last segment anchored to the deepest path segment
    within all sources (PWD, PWD+1, PWD+2, and directory stack contents)

    in a typo-tolerant way, such that if 75% of the search pattern matches, the candidate is displayed without penalty within its existing group

  to be capped to specific values
    current directory (PWD) - uncapped
    PWD+1 - capped to 12 candidates
    PWD+2 - capped to 6 candidates
    ../* / ../*/* / ../../* - capped to 6 candidates each
    Directory stack PWD+1 - capped to 6 candidates
    Directory stack PWD+2 - capped to 6 candidates

    where each segment's cap is shared by its non-hidden and hidden groups together
      non-hidden filled first, hidden taking the remaining room, none left means no hidden shown

    and I want these cap values to be configurable via zstyle

  to appear after I press TAB

  to cycle through candidates when I press TAB repeatedly

  to let me navigate candidates
    using the arrow keys
    jumping multiple candidates at a time using ALT+UpArrow and ALT+DownArrow

  to be visually grouped into categories:
    * (PWD)
    */* (PWD+1)
    */*/* (PWD+2)
    .. <parent>/* — ../* (PWD siblings)
    .. <parent>/*/* — ../*/* (siblings' children)
    ../.. <grandparent>/* — ../../* (grandparent children)
    Stack * (directory stack)
      Stack */* (stack+1)
      Stack */*/* (stack+2)
        where the Stack */* and Stack */*/* groups (stack+1, stack+2) are gated on the groups zstyle, base-only in this config

    where each up-group heading names the actual base dir it lists: the `..`-relative prefix then `<basedir>/*`

    where groups are prepended with '## name' e.g. `## *`, `## */*`, `## .. <parent>/*`, `## .. <parent>/*/*`, `## ../.. <grandparent>/*`, `## Stack *`, `## Stack */*`

    where paths render with `~` for paths under `$HOME`

  to complete absolute and `~` prefixes (`/`, `/usr/`, `~/`, `~name/`)
    with the same level groups rooted at the typed base (base `*`, base `*/*`, base `*/*/*`)
      headed `<base>/*`, `<base>/*/*`, ... with the base rendered `~`-style
    with the same per-level caps and fuzzy filtering applied to the part after the base
    with no relative-up groups
    with hints inserted as absolute (or `~`-based) paths
    with the Stack groups unchanged

  to see named dirs (`hash -d`) as their own `~*` group, placed last
    listed as `~name`, fuzzy-filtered by the typed pattern, inserting `~name/`
    skipping the entry whose target is PWD

  to see only the `~*` group for a bare `~` prefix (`~` or `~pat`, no slash)
    fuzzy-filtered by the pattern after `~`, no level, up, or stack groups

  to see a root `/` stack entry displayed and inserted as `/`, never `//`
