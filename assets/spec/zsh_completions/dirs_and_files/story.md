<!--[>] 🤖🤖🤖 -->
## Feature zsh_completions/dirs_and_files

### As a shell user

I want completion candidates whose leaf is EITHER a file OR a directory
    to show entries from
        4 levels: PWD, PWD+1, PWD+2, PWD+3 (leaf = file or dir, earlier segments dirs)
        the relative-up dirs (../*, ../*/*, ../../*, ../*/*/*)
        the directory stack contents (leaf = file or dir)

  where a directory leaf renders with a trailing `/` and a file leaf without

  to be shown in the same group order as the file completer:
    1. PWD (*)  2. PWD+1 (*/*)  3. PWD+2 (*/*/*)  4. PWD+3 (*/*/*/*)
    5. ../*  6. ../*/*  7. ../../*  8. ../*/*/*
    9. Stack */*  10. Stack */*/*

  within each group, sorted by a per-kind criterion, kinds in `file-types`
  zstyle order (default directories first then files):
    directories ordered by number of items inside, descending
    files ordered by modification time, newest first
    then hidden entries (same per-kind order), then deprioritized entries

  to allow searching (fuzzy, path-segment-aware, restricted, typo-tolerant)
  identically to the file and dir completers, across all sources

  to be capped identically to the file completer
    PWD uncapped, PWD+1 12, PWD+2 6, PWD+3 6, each ../ group 6, each Stack group 6
    where each cap is shared by a group's non-hidden and hidden entries together
    and configurable via zstyle

  to appear after TAB, cycle on repeated TAB, navigate with arrows +
  ALT+UpArrow / ALT+DownArrow, group headings identical to the file completer,
  paths rendering `~` under $HOME

  to fire for file-and-dir commands (code ls stat)
    with the trigger set extensible via zstyle/config
<!--[<] 🤖🤖🤖 -->
