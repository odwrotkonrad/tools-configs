<!--[>] 🤖🤖 -->
Feature: history completion menu

Scenario: Up/Down opens a whole-line history menu, substring-filtered by the buffer, sized to the terminal
  Status: implemented
  Given an empty or non-empty buffer
  When I press Up or Down
  Then a heading-less history menu opens, newest first, deduped
  And the menu fills the terminal rows below the prompt, leaving 2 blank rows at the bottom
  And the whole buffer substring-filters the entries, case-insensitive
  And accepting an entry replaces the whole buffer with the full command
  And entries spanning more than one row (multiline or wider than $COLUMNS) are omitted
  And entries matching an ignore-hints regex (e.g. ^cd.*) are omitted
  And Up/Down inside the open menu move the selection

Scenario: a selected entry stands alone on the line, typed words never linger beside it
  Status: implemented
  Given a non-empty buffer, the cursor anywhere (mid-word, after a trailing space, mid-line)
  When I press Up or Down and the menu highlights or accepts an entry
  Then the entry replaces the entire buffer, no typed word survives before or after it
  And when no entry matches, the typed buffer and cursor position stay untouched

Scenario: entries rank exact-case prefix, then ci prefix, then ci substring, newest first within each tier
  Status: implemented
  Given a non-empty buffer as the query
  When the history menu opens
  Then entries starting with the query in exact case rank first
  And entries starting with the query case-insensitive rank second
  And entries containing the query anywhere, case-insensitive, rank last
  And within each tier entries stay newest first, deduped
<!--[<] 🤖🤖 -->
