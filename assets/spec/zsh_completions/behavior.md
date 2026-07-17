<!--[>] 🤖🤖 -->
Feature: shared completion behavior

Scenario: command position completes grouped capped candidates
  Given I am in command position (empty line or a typed command prefix)
  When I press TAB
  Then candidates appear in alias, builtins, functions, commands groups
  And each group is capped at its max-hints count (default 6)
  And each group lists alphabetically
  And a typed prefix fuzzy-filters every group
  And a word containing a slash falls back to stock path completion
<!--[<] 🤖🤖 -->
