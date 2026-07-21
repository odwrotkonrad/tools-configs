<!--[>] 🤖🤖 -->
Feature: make target completion

Scenario: typed pattern matching no target completes nothing cleanly
  Given I have typed a pattern after make that matches no target in any group
  When I press TAB
  Then no candidates are shown and nothing is inserted
  And no error or bad-pattern message is printed
  And the typed line stays unchanged

Scenario: typed pattern matches targets anywhere in the name
  Given I have typed a pattern after make that occurs in the middle of target names
  When I press TAB
  Then targets containing the pattern anywhere in their name are shown
  And matching is case-insensitive
  And each candidate stays in its own group
<!--[<] 🤖🤖 -->
