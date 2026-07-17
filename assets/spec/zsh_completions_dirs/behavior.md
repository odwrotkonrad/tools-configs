Feature: cd deep-directory completion

Scenario: corrected candidates stay in their groups
  Given completions are shown and some have typo corrections
  When corrections are applied
  Then no extra group of corrected items appears
  And each corrected item stays within its existing group

Scenario: per-group cap limits the number of items
  Given a group has more candidates than its cap
  When completions are shown
  Then that group is limited to its cap number of items

Scenario: typed search pattern filters the candidates
  Given I have typed search pattern after cd
  When I press TAB
  Then the typed pattern stays in the command line
  And only candidates matching search pattern are shown

Scenario: hidden directories sort after visible ones within a group
  Given a group contains both hidden and visible directory candidates
  When completions are shown
  Then every visible candidate appears before every hidden candidate
  And no hidden candidate appears among the visible ones

Scenario: a level with visible candidates shows its group header
  Given a PWD level has at least one visible directory candidate
  When completions are shown
  Then that level's group carries its header (*, */*, */*/*, Stack *, Stack */*, or Stack */*/*)
  And that level's hidden candidates form an unlabeled group with no header
  And that hidden group sits directly under its own level's visible group, not after all other levels

Scenario: a level with only hidden candidates still shows its level header
  Given a PWD level has hidden directory candidates and no visible ones
  When completions are shown
  Then that level's hidden group carries its level header (*, */*, or */*/*)

Scenario: a level's visible and hidden groups share one column count
  Given a level whose visible and hidden groups would otherwise use different column counts
  When completions are shown
  Then both groups render in the same number of columns
  And that number equals the smaller of the two counts

Scenario: directory-stack entries match the typed pattern per path segment
  Given the directory stack holds absolute paths
  And I have typed a search pattern (e.g. root)
  When I press TAB
  Then a stack path is shown only when it matches the pattern in a fuzzy way

Scenario: matched stacked dirs expand to child and grandchild groups
  Given the groups zstyle lists stack+1 and stack+2
  And the directory stack holds absolute paths
  And I have typed a search pattern
  When I press TAB
  Then only stacked dirs matching the pattern are expanded
  And their matching children form a Stack */* group
  And their matching grandchildren form a Stack */*/* group
  And each of those groups is capped at 6 items
  And within each group visible candidates precede hidden ones
  And a stack level with only hidden candidates carries its header

Scenario: stack child and grandchild groups are disabled by default
  Given the groups zstyle lists only the base stack group (this config's default)
  And the directory stack holds absolute paths
  And I have typed a search pattern
  When I press TAB
  Then the base Stack * group is shown
  And no Stack */* or Stack */*/* group is shown

Scenario Outline: single-segment pattern matches only the group's own segment
  Given I have typed the search pattern "<pattern>"
  When I press TAB
  Then the pattern matches the candidate's own segment for its group
  And a match against a shallower segment does not carry a candidate into a deeper group
  And the shown candidates are exactly "<candidates>"

  Examples:
    | pattern | candidates                           |
    | rt      | root                                 |
    | data    | root/datasource, root/dir/datasource |
    | src     | root/datasource, root/dir/datasource |
    | dir     | root/dir                             |

Scenario Outline: multi-segment pattern matches segments in order, ending at the group's own segment
  Given I have typed the search pattern "<pattern>"
  When I press TAB
  Then the pattern's segments match in the order they were typed
  And each pattern segment matches fuzzily, not exactly
  And the pattern's last segment matches the candidate's own segment for its group
  And the shown candidates are exactly "<candidates>"

  Examples:
    | pattern | candidates                           |
    | da      | root/datasource, root/dir/datasource |
    | source  | root/datasource, root/dir/datasource |
    | rot/da  | root/datasource, root/dir/datasource |
    | r/src   | root/datasource, root/dir/datasource |
    | d/da    | root/dir/datasource                  |

Scenario: the relative-up groups sit after PWD levels and before the stack
  Given the up groups (../*, ../*/*, ../../*) are shown
  When completions are shown
  Then the ../* group appears after the PWD+2 group
  And the ../*/* group appears after the ../* group
  And the ../../* group appears after the ../*/* group
  And all three appear before the base Stack * group

Scenario: the relative-up groups drop the entries that duplicate other groups
  Given I have typed any search pattern or none
  When I press TAB
  Then the ../* group shows PWD's siblings but not PWD itself (../<pwdname>)
  And the ../*/* group shows siblings' children but not PWD's own children (already in ## */*)
  And the ../../* group shows grandparent children but not the parent dir (../../<parentname>, == ..)

Scenario: each relative-up group is capped and orders visible before hidden
  Given a relative-up group has more candidates than its cap
  When completions are shown
  Then that group is capped at 6 items
  And within it visible candidates precede hidden ones
  And an up group with only hidden candidates carries its header (../*, ../*/*, or ../../*)

Scenario: no search pattern shows PWD levels, the up groups, and the directory stack
  Given I have typed no search pattern
  When I press TAB
  Then the PWD group is shown
  And the PWD+1 group is shown, capped to 20 candidates
  And the PWD+2 group is shown, capped to 6 candidates
  And the ../*, ../*/*, and ../../* groups are shown, capped to 6 candidates each
  And the base Stack * group is shown
  And the Stack */* and Stack */*/* groups are not shown

Scenario: an absolute prefix "/" anchors hints to the root of filesystem
  Given I have typed an absolute prefix (e.g. / or /usr/)
  When I press TAB
  Then the level groups descend from the typed directory (<dir>/*, <dir>/*/*, <dir>/*/*/*)
  And no relative-up groups are shown
  And the pattern after the last / filters candidates fuzzily
  And selecting a candidate inserts its absolute path

Scenario: a ~ prefix anchors hints to the expanded directory
  Given I have typed ~/ or ~name/ (a named dir)
  When I press TAB
  Then the level groups descend from the expanded directory
  And candidates display and insert in ~ form

Scenario: a bare ~ prefix shows only the named-dirs group
  Given I have typed ~ or ~pat (no slash)
  When I press TAB
  Then only the ~* group is shown
  And the pattern after ~ filters the names fuzzily
  And no level, up, or stack groups are shown
  And ~name/... still completes via the anchored level groups

Scenario: named dirs form their own last group
  Given named dirs exist (hash -d)
  And I have typed no prefix or a relative pattern
  When I press TAB
  Then a ~* group listing each named dir as ~name appears after all other groups
  And the typed pattern filters the names fuzzily
  And a named dir whose target is PWD is not listed
  And selecting a name inserts ~name/

Scenario: a root stack entry stays a single slash
  Given / is on the directory stack
  When I press TAB
  Then the Stack * group shows /
  And selecting it inserts exactly /, not //

Scenario: alt+up/down scrolls the open completion menu by 3 rows
  Given the completion menu is open with a selection
  When I press alt+down
  Then the menu selection moves down 3 rows
  And no characters are inserted into the command line
  When I press alt+up
  Then the menu selection moves up 3 rows
  And no characters are inserted into the command line
