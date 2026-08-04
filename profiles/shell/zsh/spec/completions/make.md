<!--[>] 🤖🤖 -->
Feature: make target completion

Scenario: a query matches targets as a case-insensitive substring anywhere in the name
  Status: implemented
  Given a typed query occurring mid-name in targets
  When I press TAB
  Then targets containing the query anywhere in their name are listed
  And matching is case-insensitive
  And each match stays in its own group

Scenario: a query matching no target lists nothing, inserts nothing, prints no error
  Status: implemented
  Given a typed query matching no target in any group
  When I press TAB
  Then no matches are listed and nothing is inserted
  And no completion error (e.g. zsh bad pattern) is printed
  And the command line stays unchanged
<!--[<] 🤖🤖 -->
