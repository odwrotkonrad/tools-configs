<!--[>] 🤖🤖🤖 -->
## Feature zsh_completions/files

### As a shell user

I want file completion candidates
	to show files from
		4 levels: PWD, PWD+1, PWD+2, and PWD+3 (leaf = file, every earlier segment a dir)
		the directory stack contents (leaf = file)

  where a candidate's leaf is always a regular file and its earlier segments denote directories, matched in the typed order but not a strict sequence

  to be shown in order:
    1. PWD (*)
    2. PWD+1 (*/*)
    3. PWD+2 (*/*/*)
    4. PWD+3 (*/*/*/*)
    5. ../* (files in PWD siblings, PWD itself excluded)
    6. ../*/* (files in siblings' children, PWD's own files excluded)
    7. ../../* (files in grandparent children, parent dir's files excluded)
    8. ../*/*/* (files in parent's great-grandchildren, PWD descendants excluded)
    9. Directory stack contents PWD+1 (Stack */*)
    9. Directory stack contents PWD+2 (Stack */*/*)

    and within each segment, I want this specific ordering:
      non-hidden files, sorted by modification time, newest first
      hidden files, sorted by modification time, newest first

  to allow searching for files
    in a fuzzy, path-segment-aware, and restricted way (e.g., refs matches .git/refs, but not re/fs)
      with segment order preserved and the last segment anchored to the candidate's leaf file name
    within all sources (PWD, PWD+1, PWD+2, PWD+3, relative-up, and directory stack contents)

    in a typo-tolerant way, such that if 75% of the search pattern matches, the candidate is displayed without penalty within its existing group

  to be capped to specific values
    current directory (PWD) - uncapped
    PWD+1 - capped to 12 candidates
    PWD+2 - capped to 6 candidates
    PWD+3 - capped to 6 candidates
    ../* / ../*/* / ../../* / ../*/*/* - capped to 6 candidates each
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
    */*/*/* (PWD+3)
    .. <parent>/* — ../* (PWD siblings)
    .. <parent>/*/* — ../*/* (siblings' children)
    ../.. <grandparent>/* — ../../* (grandparent children)
    .. <parent>/*/*/* — ../*/*/* (parent great-grandchildren)
    Stack */* (stack+1)
    Stack */*/* (stack+2)

    where each up-group heading names the actual base dir it lists: the `..`-relative prefix then `<basedir>/*`

    where groups are prepended with '## name' e.g. `## *`, `## */*`, `## */*/*/*`, `## .. <parent>/*`, `## .. <parent>/*/*`, `## ../.. <grandparent>/*`, `## .. <parent>/*/*/*`, `## Stack */*`, `## Stack */*/*`

    where paths render with `~` for paths under `$HOME`

  to fire for file-taking commands (code vim vi nano cat less bat), not for cd
    with the trigger set extensible via zstyle/config
<!--[<] 🤖🤖🤖 -->
