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
  Given the directory stack holds absolute paths
  And I have typed a search pattern
  When I press TAB
  Then only stacked dirs matching the pattern are expanded
  And their matching children form a Stack */* group
  And their matching grandchildren form a Stack */*/* group
  And each of those groups is capped at 5 items
  And within each group visible candidates precede hidden ones
  And a stack level with only hidden candidates carries its header

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

Scenario: no search pattern shows PWD, PWD+1, and the directory stack only
  Given I have typed no search pattern
  When I press TAB
  Then the PWD group is shown
  And the PWD+1 group is shown, capped to 20 candidates
  And the PWD+2 group is not shown
  And the base Stack * group is shown
  And the Stack */* and Stack */*/* groups are not shown

Scenario: alt+up/down scrolls the open completion menu by 3 rows
  Given the completion menu is open with a selection
  When I press alt+down
  Then the menu selection moves down 3 rows
  And no characters are inserted into the command line
  When I press alt+up
  Then the menu selection moves up 3 rows
  And no characters are inserted into the command line
