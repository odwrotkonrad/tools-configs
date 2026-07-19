## Feature zsh_completions/make

### As a shell user

I want make target completion
  to complete a Makefile that runs targets in other Makefiles with
    its own targets, headed `## targets`
    each included Makefile's targets, in their own group

  to prefix an included Makefile's targets
    with the directory name they are contained in

  to cap an included Makefile's group to a configurable number of targets
    but show all of its targets once I complete within that group

  to sort a group to show as many unique prefixes as possible
    so the shown set reveals which prefixes to type to search further
