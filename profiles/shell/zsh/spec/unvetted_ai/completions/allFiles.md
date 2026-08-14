Feature: deep file-path completion (dirs for cd, files and dirs for file commands)

## Labeled Completion Hint Levels

Scenario: a level lists two completion hint groups, non-hidden and hidden, sharing one max-hints, its heading always listed
  Status: implemented
  Given a level with matches
  When matches are listed
  Then the level lists two completion hint groups: non-hidden and hidden
  And both groups share the level's max-hints: non-hidden completion hints first, hidden completion hints fill the remainder
  And the hidden group sits directly under the non-hidden group within a level
  And the heading is assigned to the level, not a group, and is always listed

Scenario: a relative completion request lists each level's own completion hints, levels in order: *, */*, */*/*, ../*, ../*/*, ../../*, Stack *, ~*
  Status: implemented
  Given an empty or relative query
  When I press TAB
  Then the levels with matches list in order: *, */*, */*/*, ../*, ../*/*, ../../*, Stack *, ~*, each relative to $PWD
  And each level lists the completion hints that belong to that level
  And the */* level's completion hints are truncated to 12
  And the */*/* level's completion hints are truncated to 6
  And the ../*, ../*/*, and ../../* levels' completion hints are truncated to 6 each

Scenario: an absolute completion request lists the levels anchored to the typed directory: <base>/*, <base>/*/*, <base>/*/*/*
  Status: implemented
  Given a typed slash-anchored prefix (/dir/, ~/ or ~name/)
  When I press TAB
  Then the levels list in order: <base>/*, <base>/*/*, <base>/*/*/*
  And the relative-up and ~* levels are omitted

Scenario: a level with only hidden matches still carries the level heading
  Status: implemented
  Given a $PWD-relative level with hidden matches and no non-hidden ones
  When matches are listed
  Then the level carries its heading (*, */*, or */*/*) above the hidden group

## Every Group

Scenario: each group's completion hints are truncated to its max-hints
  Status: implemented
  Given a group with more matches than its max-hints
  When matches are listed
  Then the group's completion hints are truncated to its max-hints

Scenario: a level's completion hints are truncated to 6 by default
  Status: implemented
  Given a level with no max-hints configured
  When matches are listed
  Then the level's completion hints are truncated to 6

Scenario: hidden dirs list after non-hidden ones within a group
  Status: implemented
  Given a group with both hidden and non-hidden matches
  When matches are listed
  Then every non-hidden match lists before every hidden match
  And no hidden match lists among the non-hidden ones

Scenario: a level's non-hidden and hidden groups list share columns count
  Status: implemented
  Given a level whose non-hidden and hidden groups would otherwise list in different column counts
  When matches are listed
  Then both groups list in the same column count
  And that count equals the smaller of the two

## Typed Query

Scenario: the query filters completion hints
  Status: implemented
  Given a typed query after cd
  When I press TAB
  Then only completion hints that match the query are listed

Scenario Outline: a query with no path separator searches a single filepath segment
  Status: implemented
  Given the typed query "<query>"
  When I press TAB
  Then the query fuzzy-matches a single filepath segment: the match's own segment for its group
  And a match against a shallower segment does not carry a match into a deeper group
  And the listed matches are exactly "<matches>"

  Examples:
    | query | matches                              |
    | rt    | root                                 |
    | data  | root/datasource, root/dir/datasource |
    | src   | root/datasource, root/dir/datasource |
    | dir   | root/dir                             |

Scenario Outline: a query with path separators divides into multiple queries, each matching path segments in order, not necessarily in exact sequence
  Status: implemented
  Given the typed query "<query>"
  When I press TAB
  Then the query divides on / into per-segment queries
  And each per-segment query fuzzy-matches a path segment, in typed order, skipped segments allowed between them
  And the last per-segment query matches the match's own segment for its group
  And the listed matches are exactly "<matches>"

  Examples:
    | query  | matches                              |
    | da     | root/datasource, root/dir/datasource |
    | source | root/datasource, root/dir/datasource |
    | rot/da | root/datasource, root/dir/datasource |
    | r/src  | root/datasource, root/dir/datasource |
    | d/da   | root/dir/datasource                  |

## Completion Hints Uniqueness Level-Aware

Scenario: ancestor levels do not include completion hints that appear in descendant level completion hints
  Status: implemented
  Given an empty or typed query
  When I press TAB
  Then the ../* level lists $PWD's siblings but omits $PWD itself (../<pwdname>, covered by the * level)
  And the ../*/* level lists siblings' children but omits $PWD's own children (covered by the */* level)
  And the ../../* level lists grandparent children but omits the parent dir (../../<parentname>, == ..)


<!--[>] 🤖🤖 -->
## Directory Stack

Scenario: stack entries fuzzy-match the query per path segment
  Status: implemented
  Given a directory stack of absolute paths
  And a typed query (e.g. root)
  When I press TAB
  Then a stack entry lists only when the query fuzzy-matches it per path segment

Scenario: stack child and grandchild groups are off by default
  Status: implemented
  Given the groups zstyle lists only the base stack group (this config's default)
  And a directory stack of absolute paths
  And a typed query
  When I press TAB
  Then the base Stack * group is listed
  And the Stack */* and Stack */*/* groups are omitted

Scenario: stack+1 and stack+2 expand matched stack entries to child and grandchild groups
  Status: implemented
  Given the groups zstyle lists stack+1 and stack+2
  And a directory stack of absolute paths
  And a typed query
  When I press TAB
  Then only stack entries matching the query expand
  And their matching children form a Stack */* group
  And their matching grandchildren form a Stack */*/* group
  And each of those groups' completion hints are truncated to 6
  And within each group non-hidden matches list before hidden ones
  And a stack level with only hidden matches carries its heading

Scenario: a root stack entry lists and inserts a single /
  Status: implemented
  Given / on the directory stack
  When I press TAB
  Then the Stack * group lists /
  And accepting it inserts exactly /, not //

## Anchored Prefix

Scenario: an absolute prefix anchors level groups to the typed directory
  Status: implemented
  Given a typed absolute prefix (e.g. / or /usr/)
  When I press TAB
  Then the level groups descend from the typed directory (<dir>/*, <dir>/*/*, <dir>/*/*/*)
  And the relative-up groups are omitted
  And the query after the last / fuzzy-matches
  And accepting a match inserts its absolute path

Scenario: a ~/ or ~name/ prefix anchors level groups to the expanded directory, keeping ~ form
  Status: implemented
  Given a typed ~/ or ~name/ prefix (a named dir)
  When I press TAB
  Then the level groups descend from the expanded directory
  And matches list and insert in ~ form

Scenario: a bare ~ lists home level groups plus the named-dirs group
  Status: implemented
  Given the typed query is exactly ~
  When I press TAB
  Then the level groups descend from $HOME in ~ form
  And the ~* group listing every named dir lists after them
  And the relative-up and stack groups are omitted

Scenario: a ~query prefix lists only the named-dirs group
  Status: implemented
  Given a typed ~query (one or more chars after ~, no slash)
  When I press TAB
  Then only the ~* group is listed
  And the query after ~ fuzzy-matches the names
  And the level, relative-up, and stack groups are omitted
  And ~name/... still completes via the anchored level groups

## Named Dirs

Scenario: named dirs list as ~name in a last ~* group, accepting inserts ~name/
  Status: implemented
  Given named dirs exist (hash -d)
  And an empty query or a relative query
  When I press TAB
  Then a ~* group listing each named dir as ~name lists after all other groups
  And the query fuzzy-matches the names
  And a named dir whose target is $PWD is omitted
  And accepting a name inserts ~name/
<!--[<] 🤖🤖 -->
