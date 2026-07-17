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

<!--[>] 🤖🤖 -->
Scenario: Up/Down opens a history completion menu
  Given any line content (empty or typed)
  When I press Up or Down
  Then a headerless history menu opens, newest first, deduped
  And the list fills the screen below the prompt, leaving 2 blank lines at the bottom
  And the whole typed line fuzzy-filters the candidates (chars in order, case-insensitive)
  And accepting a candidate replaces the whole line with the full command
  And commands spanning more than one screen line (multiline or wider than the terminal) are omitted
  And commands matching an ignore-hints regex (e.g. ^cd.*) are omitted
  And Up/Down inside the open menu move the selection
<!--[<] 🤖🤖 -->
