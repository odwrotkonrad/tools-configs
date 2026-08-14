<!--[>] 🤖🤖 -->
Feature: shared completion behavior

Scenario: alt+up/alt+down move the menu selection 3 rows without inserting characters
  Status: implemented
  Given the completion menu is open with a selection
  When I press alt+down
  Then the selection moves down 3 rows
  And no characters are inserted into the command line
  When I press alt+up
  Then the selection moves up 3 rows
  And no characters are inserted into the command line

Scenario: command-position TAB lists alphabetical, completion-hint-truncated groups fuzzy-filtered by the query
  Status: implemented
  Given the cursor is in command position (empty buffer or a typed query)
  When I press TAB
  Then matches are listed in scripts, alias, builtins, functions, commands, parameters groups
  And each group's completion hints are truncated to its max-hints (default 6)
  And each group lists alphabetically
  And the query fuzzy-matches within every group
  And a history group of history entries is listed last, completion hints truncated to 4
  And a word containing / or ~ delegates to stock _autocd path completion (/usr/bi -> /usr/bin/, ~/pro -> ~/projects/, ./ lists dirs and executables)
<!--[<] 🤖🤖 -->
