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
    4. Directory stack contents
    5. Directory stack contents PWD+1
    6. Directory stack contents PWD+2

    and within each segment, I want this specific ordering:
      non-hidden directories, sorted by the number of items inside
        with directories containing "test" placed at the end
      hidden directories, sorted by the number of items inside
      configurable low-precedence directories (e.g., .git, node_modules)

  to allow searching for directories
    in a fuzzy, path-segment-aware, and restricted way (e.g., refs matches .git/refs, but not re/fs)
      with segment order preserved and the last segment anchored to the deepest path segment
    within all sources (PWD, PWD+1, PWD+2, and directory stack contents)

    in a typo-tolerant way, such that if 75% of the search pattern matches, the candidate is displayed without penalty within its existing group

  to be capped to specific values
    current directory (PWD) - uncapped
    PWD+1 - capped to 20 candidates
    PWD+2 - capped to 5 candidates
    Directory stack PWD+1 - capped to 5 candidates
    Directory stack PWD+2 - capped to 5 candidates

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
    Stack * (directory stack)
      Stack */* (stack+1)
      Stack */*/* (stack+2)

    where groups are prepended with '## name' e.g. `## *`, `## */*`, `## Stack *`, `## Stack */*`

    where paths render with `~` for paths under `$HOME`
